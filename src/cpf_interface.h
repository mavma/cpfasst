#pragma once

// Forward declaration of Fortran routines
void cpf_probin_init();
void cpf_mpi_create();
void cpf_pfasst_create();
void cpf_user_obj_allocate(size_t* data_size);
void cpf_pfasst_setup();
void cpf_add_hook();
void cpf_print_loc_options();
void cpf_setup_ic();
void cpf_pfasst_run();
void cpf_cleanup();

void set_fname(char*);

void cpf_imex_sweeper_set_feval(void*);
void cpf_imex_sweeper_set_fcomp(void*);

// Hooks

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

// Adds a custom hook to a C callback
//      level_index: the level to add the hook for, -1 for all levels
//      hook: which type of hook to add
//      callback: pointer to callback function with the following signature:
//          void my_callback(void* pf, int* idx)
//              pf: opaque data structure which SHOULD NOT BE MODIFIED
//              idx: level the callback was called for
void cpf_add_custom_hook(int* level_index, cpf_hooks_t* hook, void(**callback)(void*,int*));

// Adds hook to the LibPFASST-provided echo_residual function
//      level_index: the level to add the hook for, -1 for all levels
//      hook: which type of hook to add
void cpf_add_echo_residual_hook(int* level_index, cpf_hooks_t* hook);