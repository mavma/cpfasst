#pragma once

#include "types.h"

// Allocate memory for with given number of array elements
ex3_data_t* ex3_data_create(size_t nx);

// Free memory for given ex3_data
void ex3_data_destroy(ex3_data_t* data);

// Calculate size in memory of data with nx array elements
size_t ex3_data_get_size(size_t nx);