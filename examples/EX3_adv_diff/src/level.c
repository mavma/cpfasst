#include <cpf_level.h>

#include <string.h>
#include <assert.h>
#include "shared.h"
#include "fft_tool.h"

void cpf_level_interpolate_cb(int f_level_index, int c_level_index, user_data_t* f_data, user_data_t* c_data, double t) {
    ex3_data_t *f_data_ = (ex3_data_t*) f_data;
    ex3_data_t *c_data_ = (ex3_data_t*) c_data;

    fft_tool_t *fft_f = sweepers[f_level_index-1]->fft_tool;
    fft_tool_t *fft_c = sweepers[c_level_index-1]->fft_tool;
    int irat  = f_data_->nx / c_data_->nx;

    assert(f_data_->nx == irat * c_data_->nx); // ratio is integer
    assert(irat == 1 || irat == 2);

    switch(irat) {
        case 1: // identity map
            memcpy(f_data_->array, c_data_->array, f_data_->nx * sizeof(double));
            break;
        case 2: // use spectral space
            interp_1d(fft_c, c_data_->array, fft_f, f_data_->array);
            break;
    }
}

void cpf_level_restrict_cb(int f_level_index, int c_level_index, user_data_t* f_data, user_data_t* c_data, double t) {
    ex3_data_t *f_data_ = (ex3_data_t*) f_data;
    ex3_data_t *c_data_ = (ex3_data_t*) c_data;

    int irat  = f_data_->nx / c_data_->nx;
    assert(f_data_->nx == irat * c_data_->nx); // ratio is integer

    // pointwise coarsening
    for(int i=0; i<c_data_->nx; i++) c_data_->array[i] = f_data_->array[i*irat];
}