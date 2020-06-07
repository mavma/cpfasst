#pragma once

#include "cpf_parameters.h"

// Mandatory function calls for a cpfasst run (in this order):
//
// 0. MPI_Initialize(...)
// 1. cpf_initialize(...) -> allocate and initialize parameter structures
// 2. for each level: cpf_allocate_level(...) -> allocate and initialize levels
// 3. cpf_run(...) -> trigger pfasst main loop
// 4. cpf_destroy(...) -> free Fortran-allocated memory


/*
 * Function:  cpf_initialize_pfasst
 * --------------------
 * Initialize pfasst parameters and data structures. Must be called with ONE of the parameters (the unused parameter
 * must be set to NULL). This call must be preceded by an MPI_Initialize call. After this call, the user may modify
 * pfasst parameters using cpf_get_parameters and cpf_set_parameters.
 *
 *  [in] nml_file_path: C string containing path to nml file to initialize parameters from. Parameters not set by the
 *          nml file are initialized to default values.
 *  [in] nlevels: pointer to number of pfasst levels. All parameters other than the number of levels are initialized to
 *          default values.
 */
void cpf_initialize_pfasst(char* nml_file_path, int* nlevels);

/*
 * Function:  cpf_initialize_level
 * --------------------
 * Allocate and initialize user levels and related structures. Must be called once for every pfasst level.
 *
 *  [in] level_index: 1-based index of level to be initialized
 *  [in] data_size: size in bytes of user-allocated data for this level (used for MPI communication)
 */
void cpf_initialize_level(int* level_index, int* data_size);

/*
 * Function:  cpf_set_initial_condition
 * --------------------
 * Set initial condition for run in user-defined data format
 *
 *  [in] data: user_data_t containing to initial condition
 */
void cpf_set_initial_condition(user_data_t** data);

/*
 * Function:  cpf_set_final_condition
 * --------------------
 * Set storage for final solution of run
 *
 *  [in] data: allocated user_data_t, will be set by LibPFASST to final solution at the end of the run
 */
void cpf_set_final_solution(user_data_t** data);

/*
 * Function:  cpf_run
 * --------------------
 * Trigger the main pfasst loop. Must be called with tend OR nstep (the unused parameter must be set to NULL).
 *
 *  [in] dt: time step size
 *  [in] tend: end time of the run
 *  [in] nsteps: number of steps to run
 */
void cpf_run(double* dt, double* tend, int* nsteps);

/*
 * Function:  cpf_destroy
 * --------------------
 * Free Fortran-allocated memory for the run
 */
void cpf_destroy();

// Get pointer to current solution at given level
user_data_t* cpf_get_current_solution(int level_index);

// Get time at current endpoint
double cpf_get_endpoint_time();

