#include "shared.h"
#include <quadmath.h>

ex3_prm_t ex3_prm;
ex3_sweeper_t *sweepers[PF_MAXLEVS];
const double TWOPI = (double) (M_PIq * 2.0Q);