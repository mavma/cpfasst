#pragma once

// Static parameters - must always match LibPFASST

#define PF_MAXLEVS 4

typedef enum {
    PF_PRE_PREDICTOR     = 1,
    PF_POST_PREDICTOR    = 2,
    PF_PRE_ITERATION     = 3,
    PF_POST_ITERATION    = 4,
    PF_PRE_SWEEP         = 5,
    PF_POST_SWEEP        = 6,
    PF_PRE_BLOCK         = 7,
    PF_POST_BLOCK        = 8,
    PF_PRE_INTERP_ALL    = 9,
    PF_POST_INTERP_ALL   = 10,
    PF_PRE_INTERP_Q0     = 11,
    PF_POST_INTERP_Q0    = 12,
    PF_PRE_RESTRICT_ALL  = 13,
    PF_POST_RESTRICT_ALL = 14,
    PF_PRE_CONVERGENCE   = 15,
    PF_POST_CONVERGENCE  = 16,
    PF_POST_ALL          = 17
} cpf_hooks_t;

// User encapsulated data type definition for interface readability
typedef void user_encap_t;