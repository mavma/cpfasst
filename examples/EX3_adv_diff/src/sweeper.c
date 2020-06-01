#include <cpf_imex_sweeper.h>

#include <stdio.h>
#include <stdlib.h>
#include <assert.h>
#include "utils.h"
#include "shared.h"
#include "fft_tool.h"

void imex_sweeper_initialize_cb(int* level_index, bool* explicit, bool* implicit) {
    int lev_idx = *level_index - 1; // zero-indexed level
    int nx = local_prm.nx[lev_idx]; // number of nodes at this level

    // allocate sweeper
    my_sweeper_t *this = (my_sweeper_t*) calloc_and_check(1, sizeof(my_sweeper_t));
    sweepers[lev_idx] = this;

    // allocate and initialize fft tool
    this->fft_tool = (fft_tool_t*) calloc_and_check(1, sizeof(fft_tool_t));
    fft_setup(this->fft_tool, nx, local_prm.Lx);

    // define spectral derivative operators
    complex double lap[nx], ddx[nx];
    make_lap_1d(this->fft_tool, lap);
    make_deriv_1d(this->fft_tool, ddx);

    // allocate operators
    this->opE = (complex double*) calloc_and_check(nx, sizeof(complex double));
    this->opI = (complex double*) calloc_and_check(nx, sizeof(complex double));
    this->tmp = (complex double*) calloc_and_check(nx, sizeof(complex double));

    // set variables and operators for explicit and implicit parts depending on imex_stat
    switch(local_prm.imex_stat) {
        case 0: // fully explicit
            *explicit = true;
            *implicit = false;
            for(int i=0; i<nx; i++) {
                this->opE[i] = - local_prm.v * ddx[i] + local_prm.nu * lap[i];
                this->opI[i] = 0.0;
            }
            break;
        case 1: // fully implicit
            *explicit = false;
            *implicit = true;
            for(int i=0; i<nx; i++) {
                this->opE[i] = 0.0;
                this->opI[i] = - local_prm.v * ddx[i] + local_prm.nu * lap[i];
            }
            break;
        case 2: // IMEX
            *explicit = true;
            *implicit = true;
            for(int i=0; i<nx; i++) {
                this->opE[i] = - local_prm.v * ddx[i];
                this->opI[i] = local_prm.nu * lap[i];
            }
            break;
        default:
            stop("Invalid value for imex_stat");
    }

}

void imex_sweeper_destroy_cb(int* level_index) {
    my_sweeper_t *this = sweepers[*level_index - 1];

    // destroy and deallocate fft tool
    fft_destroy(this->fft_tool);
    free(this->fft_tool);
    // deallocate FFT operators
    free(this->opE);
    free(this->opI);
    free(this->tmp);
    // deallocate sweeper
    free(this);
}

void imex_sweeper_f_eval_cb(void** y, double* t, int* level_index, void** f, int* piece) {
    my_sweeper_t *this = sweepers[*level_index - 1];
    my_data_t *y_ = (my_data_t*) (*y);
    my_data_t *f_ = (my_data_t*) (*f);

    switch(*piece) {
        case 1: // Explicit piece
            conv_1d(this->fft_tool, y_->array, this->opE, f_->array);
            break;
        case 2: // Implicit piece
            conv_1d(this->fft_tool, y_->array, this->opI, f_->array);
            break;
        default:
            stop("Bad case for piece in f_eval");
    }
    return;
}

void imex_sweeper_f_comp_cb(void** y, double* t, double* dtq, void** rhs, int* level_index, void** f, int* piece) {
    my_sweeper_t *this = sweepers[*level_index - 1];
    my_data_t *y_ = (my_data_t*) (*y);
    my_data_t *f_ = (my_data_t*) (*f);
    my_data_t *rhs_ = (my_data_t*) (*rhs);

    if(local_prm.imex_stat == 0) {
        printf("cpfasst: We should not be calling fcomp for fully explicit");
        for(int i=0; i<y_->size; i++) {
            y_->array[i] = rhs_->array[i];
            f_->array[i] = 0;
        }
        return;
    }

    switch(*piece) {
        case 2:
            // Apply the inverse operator with the FFT convolution
            for(int i=0; i<y_->size; i++) this->tmp[i] = 1.0/(1.0 - (*dtq)*this->opI[i]);
            conv_1d(this->fft_tool, rhs_->array, this->tmp, y_->array);
            for(int i=0; i<y_->size; i++) f_->array[i] = (y_->array[i] - rhs_->array[i]) / *dtq;
            break;
        default:
            stop("Bad case for piece in f_eval");
    }
    return;
}