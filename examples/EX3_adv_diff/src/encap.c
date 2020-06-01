// Encapsulation for 1D arrays

#include <cpf_encap.h>

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <math.h>
#include <assert.h>
#include "utils.h"

#include "shared.h"

// TODO: deal with shape in C only
void factory_create_cb(void** data, int* level_index, int** lev_shape, int* lev_shape_len) {
    *data = malloc(sizeof(my_data_t));
    my_data_t *data_ = (my_data_t*) (*data);
    int level_index_ = *level_index - 1;
    // allocate 1D array
    data_->size = local_prm.nx[level_index_];
    data_->array = (double*) calloc_and_check(data_->size, sizeof(double));
}

void factory_destroy_cb(void** data) {
    my_data_t *data_ = (my_data_t*) (*data);
    free(data_->array);
    free(data_);
}

void encap_setval_cb(void** data, double* value, int* flags) {
    my_data_t *data_ = (my_data_t*) (*data);
    for(int i = 0; i < data_->size; i++) {
        data_->array[i] = *value;
    }
}

void encap_copy_cb(void** dst, void** src, int* flags) {
    my_data_t *dst_ = (my_data_t*) (*dst);
    my_data_t *src_ = (my_data_t*) (*src);
    assert(dst_->size == src_->size);
    memcpy(dst_->array, src_->array, dst_->size*sizeof(double));
}

double encap_norm_cb(void** data, int* flags) {
    my_data_t *data_ = (my_data_t*) (*data);
    double max = 0;
    for(int i = 0; i < data_->size; i++) {
        double abs = fabs(data_->array[i]);
        max = (abs > max) ? abs : max;
    }
    return(max);
}

void encap_axpy_cb(void** y, double* a, void** x, int* flags) {
    my_data_t *y_ = (my_data_t*) (*y);
    my_data_t *x_ = (my_data_t*) (*x);
    assert(y_->size == x_->size);
    if(*a == 0) return;
    for(int i = 0; i < y_->size; i++) y_->array[i] += (*a) * x_->array[i];
}

void encap_eprint_cb(void** data, int* flags) {
    my_data_t *data_ = (my_data_t*) (*data);
    int nprint = (data_->size < 10) ? data_->size : 10;
    for(int i = 0; i < nprint; i++)
        printf("  %.16E", data_->array[i]);
    printf("\n");
}