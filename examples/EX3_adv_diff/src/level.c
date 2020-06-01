#include <cpf_level.h>

#include <string.h>
#include <assert.h>
#include "shared.h"
#include "fft_tool.h"

void level_interpolate(int f_idx, int c_idx, my_data_t* f_data, my_data_t* c_data) {
    fft_tool_t *fft_f = sweepers[f_idx]->fft_tool;
    fft_tool_t *fft_c = sweepers[c_idx]->fft_tool;
    int irat  = f_data->size / c_data->size;

    assert(f_data->size == irat * c_data->size);
    assert(irat == 1 || irat == 2);

    switch(irat) {
        case 1: //  Identity map
            memcpy(f_data->array, c_data->array, f_data->size * sizeof(double));
            break;
        case 2: //  Use spectral space
            interp_1d(fft_c, c_data->array, fft_f, f_data->array);
            break;
    }
}

void level_restrict(my_data_t* f_data, my_data_t* c_data) {
    int irat  = f_data->size / c_data->size;
    assert(f_data->size == irat * c_data->size);

    // Pointwise coarsening
    for(int i=0; i<c_data->size; i++)
        c_data->array[i] = f_data->array[i*irat];
}

void level_interpolate_cb(int* f_level_index, int* c_level_index, void** f_data, void** c_data, double* t, int* flags) {
    level_interpolate(*f_level_index-1, *c_level_index-1, *f_data, *c_data);
}

void level_restrict_cb(int* f_level_index, int* c_level_index, void** f_data, void** c_data, double* t, int* flags){
    level_restrict(*f_data, *c_data);
}