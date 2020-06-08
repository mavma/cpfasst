#include "types.h"
#include <cpf_level.h>

#include <string.h>
#include <assert.h>
#include "shared.h"
#include "fft_tool.h"

void cpf_level_interpolate_cb(int f_level_index, int c_level_index, user_data_t* f_data, user_data_t* c_data, double t) {
    fft_tool_t *fft_f = sweepers[f_level_index-1]->fft_tool;
    fft_tool_t *fft_c = sweepers[c_level_index-1]->fft_tool;
    int irat  = f_data->nx / c_data->nx;

    assert(f_data->nx == irat * c_data->nx); // ratio is integer
    assert(irat == 1 || irat == 2);

    switch(irat) {
        case 1: // identity map
            memcpy(f_data->arr, c_data->arr, f_data->nx * sizeof(double));
            break;
        case 2: // use spectral space
            interp_1d(fft_c, c_data->arr, fft_f, f_data->arr);
            break;
    }
}

void cpf_level_restrict_cb(int f_level_index, int c_level_index, user_data_t* f_data, user_data_t* c_data, double t) {
    int irat  = f_data->nx / c_data->nx;
    assert(f_data->nx == irat * c_data->nx); // ratio is integer

    // pointwise coarsening
    for(int i=0; i<c_data->nx; i++) c_data->arr[i] = f_data->arr[i*irat];
}