#include "types.h"
#include <cpf_encap.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <math.h>

void cpf_factory_create_cb(encap_data_t** data, int level_index) {
    *data = malloc(sizeof(ex2_data_t));
}

void cpf_factory_destroy_cb(encap_data_t* data) {
    free(data);
}

void cpf_encap_setval_cb(encap_data_t* data, double value) {
    data->val = value;
}

void cpf_encap_copy_cb(encap_data_t* dst, encap_data_t* src) {
    memcpy(dst, src, sizeof(ex2_data_t));
}

double cpf_encap_norm_cb(encap_data_t* data) {
    return(fabs(data->val));
}

void cpf_encap_axpy_cb(encap_data_t* y, double a, encap_data_t* x) {
    y->val += a * x->val;
}

void cpf_encap_eprint_cb(encap_data_t* data) {
    printf("  %.16E\n", data->val);
}