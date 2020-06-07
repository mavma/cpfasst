// Callback functions that must be defined by the user for the data encapsulation

#pragma once

#include <stddef.h>
#include "cpf_static.h"

// Allocate user-defined data for a level (1-based index)
void cpf_factory_create_cb(user_data_t** data, int level_index);

// Deallocate user-defined data
void cpf_factory_destroy_cb(user_data_t* data);

// Set data to provided scalar value
void cpf_encap_setval_cb(user_data_t* data, double value);

// Copy src to dst
void cpf_encap_copy_cb(user_data_t* dst, user_data_t* src);

// Compute norm
double cpf_encap_norm_cb(user_data_t* data);

// Compute y = a*x+y
void cpf_encap_axpy_cb(user_data_t* y, double a, user_data_t* x);

// Print data to standard output (for debugging purposes)
void cpf_encap_eprint_cb(user_data_t* data);