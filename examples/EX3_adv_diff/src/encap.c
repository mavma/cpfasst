#include "cpf_encap.h"

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <math.h>

#include "local.h"

void factory_create_cb(void** data, int* level_index, int** lev_shape, int* lev_shape_len) {
    *data = malloc(sizeof(custom_data_t));
    custom_data_t *cdata = (custom_data_t*) (*data);
    // Initial condition
    cdata->y = 1.0;
}

void factory_destroy_cb(void** data) {
    free(*data);
}

void encap_setval_cb(void** data, double* value, int* flags) {
    custom_data_t *cdata = (custom_data_t*) (*data);
    cdata->y = *value;
}

void encap_copy_cb(void** data, void** src, int* flags) {
    memcpy(*data, *src, sizeof(custom_data_t));
}

double encap_norm_cb(void** data, int* flags) {
    custom_data_t *cdata = (custom_data_t*) (*data);
    return(fabs(cdata->y));
}

void encap_axpy_cb(void** y, double* a, void** x, int* flags) {
    custom_data_t *cy = (custom_data_t*) (*y);
    custom_data_t *cx = (custom_data_t*) (*x);
    cy->y += (*a) * cx->y;
}

void encap_eprint_cb(void** data, int* flags) {
    custom_data_t *cdata = (custom_data_t*) (*data);
    printf("  %.16E\n", cdata->y);
}