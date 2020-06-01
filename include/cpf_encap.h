#pragma once

#include <stddef.h>

// Allocate data
void factory_create_cb(void** data, int* level_index, int** lev_shape, int* lev_shape_len);
// Free data
void factory_destroy_cb(void** data);
// Set data = value
void encap_setval_cb(void** data, double* value, int* flags);
// Copy src to dst
void encap_copy_cb(void** dst, void** src, int* flags);
// Compute norm(data)
double encap_norm_cb(void** data, int* flags);
// Compute y = a x + y
void encap_axpy_cb(void** y, double* a, void** x, int* flags);
// Print data for debugging purposes
void encap_eprint_cb(void** data, int* flags);