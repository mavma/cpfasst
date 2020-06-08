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

/* LibPFASST sends the data for a user_data_t through MPI as an array of double.
 * This imposes the following requirements on the data format
 *     1. data for a user_data_t must be stored in contiguous memory
 *     2. size of one user_data_t must be a multiple of sizeof(double)
 *     3. data should not contain pointers (even to itself), as they can't be dereferenced on other processors
 *
 * In this example, C99's flexible array member is used in ex3_data_t to create a compliant structure
 */

ex3_data_t* ex3_data_create(size_t nx) {
    ex3_data_t* data = (ex3_data_t*) malloc_and_check(ex3_data_get_size(nx));
    data->nx = nx;
    return data;
}

void ex3_data_destroy(ex3_data_t* data) {
    free(data);
}

size_t ex3_data_get_size(size_t nx) {
    size_t size = sizeof(user_data_t) + nx * sizeof(double);
    // pad to a multiple of sizeof(double) if needed
    size += (size%sizeof(double) == 0) ? 0 : sizeof(double) - size%sizeof(double);
    return size;
}

void cpf_factory_create_cb(user_data_t** data, int level_index) {
    int nx = ex3_prm.nx[level_index-1];
    *data = ex3_data_create(nx);
}

void cpf_factory_destroy_cb(user_data_t* data) {
    ex3_data_destroy(data);
}

void cpf_encap_setval_cb(user_data_t* data, double value) {
    for(int i = 0; i < data->nx; i++) data->arr[i] = value;
}

void cpf_encap_copy_cb(user_data_t* dst, user_data_t* src) {
    assert(dst->nx == src->nx);
    memcpy(dst->arr, src->arr, dst->nx*sizeof(double));
}

double cpf_encap_norm_cb(user_data_t* data) {
    double max = 0;
    for(int i = 0; i < data->nx; i++) {
        double abs = fabs(data->arr[i]);
        max = (abs > max) ? abs : max;
    }
    return max;
}

void cpf_encap_axpy_cb(user_data_t* y, double a, user_data_t* x) {
    assert(y->nx == x->nx);
    if(a == 0) return;
    for(int i = 0; i < y->nx; i++) y->arr[i] += a * x->arr[i];
}

void cpf_encap_eprint_cb(user_data_t* data) {
    // logs 5 first and 5 last array members
    for(int i = 0; i < 5; i++) debug_log("%.16E ", data->arr[i]);
    for(int i = data->nx-5; i < data->nx; i++) debug_log("%.16E ", data->arr[i]);
    printf("\n");
}