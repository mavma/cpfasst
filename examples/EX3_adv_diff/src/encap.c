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

void cpf_factory_create_cb(user_data_t** data, int level_index) {
    int nx = ex3_prm.nx[level_index-1];
    *data = (user_data_t*) ex3_data_create(nx);
}

void cpf_factory_destroy_cb(user_data_t* data) {
    ex3_data_destroy((ex3_data_t*) data);
}

void cpf_encap_setval_cb(user_data_t* data, double value) {
    ex3_data_t *data_ = (ex3_data_t*) data;
    for(int i = 0; i < data_->nx; i++) {
        data_->array[i] = value;
    }
}

void cpf_encap_copy_cb(user_data_t* dst, user_data_t* src) {
    ex3_data_t *dst_ = (ex3_data_t*) dst;
    ex3_data_t *src_ = (ex3_data_t*) src;
    assert(dst_->nx == src_->nx);
    memcpy(dst_->array, src_->array, dst_->nx*sizeof(double));
}

double cpf_encap_norm_cb(user_data_t* data) {
    ex3_data_t *data_ = (ex3_data_t*) data;
    double max = 0;
    for(int i = 0; i < data_->nx; i++) {
        double abs = fabs(data_->array[i]);
        max = (abs > max) ? abs : max;
    }
    return(max);
}

void cpf_encap_axpy_cb(user_data_t* y, double a, user_data_t* x) {
    ex3_data_t *y_ = (ex3_data_t*) y;
    ex3_data_t *x_ = (ex3_data_t*) x;
    assert(y_->nx == x_->nx);
    if(a == 0) return;
    for(int i = 0; i < y_->nx; i++) y_->array[i] += a * x_->array[i];
}

void cpf_encap_eprint_cb(user_data_t* data) {
    ex3_data_t *data_ = (ex3_data_t*) data;
    int nprint = (data_->nx < 10) ? data_->nx : 10;
    for(int i = 0; i < nprint; i++)
        printf("  %.16E", data_->array[i]);
    printf("\n");
}