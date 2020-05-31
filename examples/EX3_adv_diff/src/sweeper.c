#include <assert.h>
#include <cpf_imex_sweeper.h>
#include <cpf_utils.h>
#include "local.h"
#include "fft_tool.h"

void imex_sweeper_initialize_cb(int* level_index, bool* explicit, bool* implicit) {
    int lev_idx = *level_index - 1; // zero-indexed level
    int nx = local_prm.nx[lev_idx]; // number of nodes at this level

    // allocate sweeper
    my_sweeper_t *this = (my_sweeper_t*) cpf_calloc_and_check(1, sizeof(my_sweeper_t));
    sweepers[lev_idx] = this;

    // allocate and initialize fft tool
    this->fft_tool = (fft_tool_t*) cpf_calloc_and_check(1, sizeof(fft_tool_t));
    fft_setup(this->fft_tool, nx, local_prm.Lx);

    // define spectral derivative operators
    complex double lap[nx], ddx[nx];
    make_lap_1d(this->fft_tool, lap);
    make_deriv_1d(this->fft_tool, ddx);

    // allocate operators for implicit and explicit parts
    this->opE = (complex double*) cpf_calloc_and_check(nx, sizeof(complex double));
    this->opI = (complex double*) cpf_calloc_and_check(nx, sizeof(complex double));

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
        default: cpf_stop("Invalid value for imex_stat");
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
    // deallocate sweeper
    free(this);
}

void imex_sweeper_f_eval_cb(void** y, double* t, int* level_index, void** f, int* piece) {
    custom_data_t *cy = (custom_data_t*) (*y);
    custom_data_t *cf = (custom_data_t*) (*f);

    switch(*piece) {
        case 1: // Explicit piece
            cf->y = local_prm.lam1*cy->y;
            break;
        case 2: // Implicit piece
            cf->y = local_prm.lam2*cy->y;
            break;
        default:
            printf("Bad case for piece in f_eval: %d", *piece);
            exit(0);
            break;
    }
    return;
}

void imex_sweeper_f_comp_cb(void** y, double* t, double* dtq, void** rhs, int* level_index, void** f, int* piece) {
    custom_data_t *cy = (custom_data_t*) (*y);
    custom_data_t *cf = (custom_data_t*) (*f);
    custom_data_t *crhs = (custom_data_t*) (*rhs);

    switch(*piece) {
        case 2:
            cy->y = crhs->y/(1.0 - (*dtq)*local_prm.lam2);
            cf->y = (cy->y - crhs->y)/(*dtq);
            break;
        default:
            printf("Bad case for piece in f_comp: %d", *piece);
            exit(0);
            break;
    }
    return;
}