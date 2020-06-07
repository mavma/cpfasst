// Functions handling the user-defined encapsulation for 1D arrays
#include "encap.h"      // problem-specific functions defined here
#include <cpf_encap.h>  // cpfasst callbacks defined here

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <math.h>
#include <assert.h>
#include "utils.h"
#include "shared.h"

ex3_data_t* ex3_data_create(size_t nx) {
    ex3_data_t* data = (ex3_data_t*) calloc_and_check(1, sizeof(ex3_data_t));
    data->nx = nx;
    data->array = (double*) calloc_and_check(data->nx, sizeof(double));
    return data;
}

void ex3_data_destroy(ex3_data_t* data) {
    free(data->array);
    free(data);
}

size_t ex3_data_get_size(ex3_data_t* data) {
    return(sizeof(ex3_data_t) + data->nx * sizeof(double));
}

// TODO: deal with shape in C only, call local function
void factory_create_cb(void** data, int* level_index, int** lev_shape, int* lev_shape_len) {
    *data = malloc(sizeof(ex3_data_t));
    ex3_data_t *data_ = (ex3_data_t*) (*data);
    int level_index_ = *level_index - 1;
    // allocate 1D array
    data_->nx = ex3_prm.nx[level_index_];
    data_->array = (double*) calloc_and_check(data_->nx, sizeof(double));
}

// TODO: call local function
void factory_destroy_cb(void** data) {
    ex3_data_t *data_ = (ex3_data_t*) (*data);
    free(data_->array);
    free(data_);
}

void encap_setval_cb(void** data, double* value, int* flags) {
    ex3_data_t *data_ = (ex3_data_t*) (*data);
    for(int i = 0; i < data_->nx; i++) {
        data_->array[i] = *value;
    }
}

void encap_copy_cb(void** dst, void** src, int* flags) {
    ex3_data_t *dst_ = (ex3_data_t*) (*dst);
    ex3_data_t *src_ = (ex3_data_t*) (*src);
    assert(dst_->nx == src_->nx);
    memcpy(dst_->array, src_->array, dst_->nx*sizeof(double));
}

double encap_norm_cb(void** data, int* flags) {
    ex3_data_t *data_ = (ex3_data_t*) (*data);
    double max = 0;
    for(int i = 0; i < data_->nx; i++) {
        double abs = fabs(data_->array[i]);
        max = (abs > max) ? abs : max;
    }
    return(max);
}

void encap_axpy_cb(void** y, double* a, void** x, int* flags) {
    ex3_data_t *y_ = (ex3_data_t*) (*y);
    ex3_data_t *x_ = (ex3_data_t*) (*x);
    assert(y_->nx == x_->nx);
    if(*a == 0) return;
    for(int i = 0; i < y_->nx; i++) y_->array[i] += (*a) * x_->array[i];
}

void encap_eprint_cb(void** data, int* flags) {
    ex3_data_t *data_ = (ex3_data_t*) (*data);
    int nprint = (data_->nx < 10) ? data_->nx : 10;
    for(int i = 0; i < nprint; i++)
        printf("  %.16E", data_->array[i]);
    printf("\n");
}