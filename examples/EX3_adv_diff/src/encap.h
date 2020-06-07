#pragma once

#include "types.h"

// Allocate memory for ex3_data_t with given size
ex3_data_t* ex3_data_create(size_t size);

// Free memory for given ex3_data
void ex3_data_destroy(ex3_data_t* data);

// Calculate size in bytes of given ex3_data_t
size_t ex3_data_get_size(ex3_data_t* data);