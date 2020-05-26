// Encapsulation for 1D arrays

#include "cpf_encap.h"

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <math.h>
#include <assert.h>

#include "local.h"

void factory_create_cb(void** data, int* level_index, int** lev_shape, int* lev_shape_len) {
    *data = malloc(sizeof(custom_data_t));
    custom_data_t *cdata = (custom_data_t*) (*data);
    // allocate 1D array data
    assert(*lev_shape_len == 1);
    cdata->size = *lev_shape[0];
    cdata->array = (double*) calloc(cdata->size, sizeof(double));
    // Initial condition
    // cdata->y = 1.0; FIXME
}

void factory_destroy_cb(void** data) {
    custom_data_t *cdata = (custom_data_t*) (*data);
    free(cdata->array);
    free(*data);
}

void encap_setval_cb(void** data, double* value, int* flags) {
    custom_data_t *cdata = (custom_data_t*) (*data);
    for(int i = 0; i < cdata->size; i++) cdata->array[i] = *value;
}

void encap_copy_cb(void** data, void** src, int* flags) {
    memcpy(*data, *src, sizeof(custom_data_t));
}

double encap_norm_cb(void** data, int* flags) {
    custom_data_t *cdata = (custom_data_t*) (*data);
    // like LibPFASST's ndarray, we use the max norm
    double max = 0;
    for(int i = 0; i < cdata->size; i++)
        max = (fabs(cdata->array[i]) > max) ? fabs(cdata->array[i]) : max;
    return(max);
}

void encap_axpy_cb(void** y, double* a, void** x, int* flags) {
    custom_data_t *cy = (custom_data_t*) (*y);
    custom_data_t *cx = (custom_data_t*) (*x);
    for(int i = 0; i < cy->size; i++)
        cy->array[i] += (*a) * cx->array[i];
}

void encap_eprint_cb(void** data, int* flags) {
    custom_data_t *cdata = (custom_data_t*) (*data);
    for(int i = 0; i < cdata->size; i++)
        printf("  %.16E", cdata->array[i]);
    printf("\n");
}