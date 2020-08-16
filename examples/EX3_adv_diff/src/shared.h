// Shared variables
#pragma once

#include <cpf_static.h>
#include "types.h"

// user parameters for this run
extern ex3_prm_t ex3_prm;

// sweepers for each of the levels
extern ex3_sweeper_t *sweepers[PF_MAXLEVS];

// 2*PI constant
extern const double TWOPI;