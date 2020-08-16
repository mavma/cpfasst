#pragma once

#include "types.h"

// compute exact solution at time t
void compute_exact_solution(encap_data_t* y, double t);

// compute error for given solution at time t
double compute_error(encap_data_t* y, double t);