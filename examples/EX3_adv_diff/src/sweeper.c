#include "types.h"
#include <cpf_imex_sweeper.h>
#include <stdio.h>
#include <stdlib.h>
#include <assert.h>
#include "utils.h"
#include "shared.h"
#include "fft_tool.h"

void cpf_imex_sweeper_initialize_cb(int level_index, bool* explicit, bool* implicit) {
    int nx = ex3_prm.nx[level_index-1]; // number of nodes at this level

    // allocate sweeper
    ex3_sweeper_t *this = (ex3_sweeper_t*) malloc_and_check(sizeof(ex3_sweeper_t));
    sweepers[level_index-1] = this;

    // allocate and initialize fft tool
    this->fft_tool = (fft_tool_t*) malloc_and_check(sizeof(fft_tool_t));
    fft_setup(this->fft_tool, nx, ex3_prm.Lx);

    // define spectral derivative operators
    complex double lap[nx], ddx[nx];
    make_lap_1d(this->fft_tool, lap);
    make_deriv_1d(this->fft_tool, ddx);

    // allocate operators
    this->opE = (complex double*) malloc_and_check(nx*sizeof(complex double));
    this->opI = (complex double*) malloc_and_check(nx*sizeof(complex double));
    this->tmp = (complex double*) malloc_and_check(nx*sizeof(complex double));

    // set variables and operators for explicit and implicit parts depending on imex_stat
    switch(ex3_prm.imex_stat) {
        case 0: // fully explicit
            *explicit = true;
            *implicit = false;
            for(int i=0; i<nx; i++) {
                this->opE[i] = - ex3_prm.v * ddx[i] + ex3_prm.nu * lap[i];
                this->opI[i] = 0.0;
            }
            break;
        case 1: // fully implicit
            *explicit = false;
            *implicit = true;
            for(int i=0; i<nx; i++) {
                this->opE[i] = 0.0;
                this->opI[i] = - ex3_prm.v * ddx[i] + ex3_prm.nu * lap[i];
            }
            break;
        case 2: // IMEX
            *explicit = true;
            *implicit = true;
            for(int i=0; i<nx; i++) {
                this->opE[i] = - ex3_prm.v * ddx[i];
                this->opI[i] = ex3_prm.nu * lap[i];
            }
            break;
        default:
            stop("Invalid value for imex_stat");
    }
}

void cpf_imex_sweeper_destroy_cb(int level_index) {
    ex3_sweeper_t *this = sweepers[level_index-1];

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

void cpf_imex_sweeper_f_eval_cb(user_data_t* y, double t, int level_index, user_data_t* f, int piece) {
    ex3_sweeper_t *this = sweepers[level_index-1];

    switch(piece) {
        case 1: // Explicit piece
            conv_1d(this->fft_tool, y->arr, this->opE, f->arr);
            break;
        case 2: // Implicit piece
            conv_1d(this->fft_tool, y->arr, this->opI, f->arr);
            break;
        default:
            stop("Bad case for piece in f_eval");
    }
    return;
}

void cpf_imex_sweeper_f_comp_cb(user_data_t* y, double t, double dtq, user_data_t* rhs, int level_index, user_data_t* f) {
    ex3_sweeper_t *this = sweepers[level_index-1];

    if(ex3_prm.imex_stat == 0) {
        // fully explicit TODO:necessary? test
        for(size_t i=0; i < y->nx; i++) {
            y->arr[i] = rhs->arr[i];
            f->arr[i] = 0;
        }
        return;
    }

    // Apply the inverse operator with the FFT convolution
    for(size_t i=0; i < y->nx; i++) this->tmp[i] = 1.0/(1.0 - dtq*this->opI[i]);
    conv_1d(this->fft_tool, rhs->arr, this->tmp, y->arr);
    for(size_t i=0; i < y->nx; i++) f->arr[i] = (y->arr[i] - rhs->arr[i]) / dtq;

    return;
}