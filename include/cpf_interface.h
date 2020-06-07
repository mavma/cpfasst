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
 * must be set to null). This call must be preceded by an MPI_Initialize call. After this call, the user may modify
 * pfasst parameters using cpf_get_parameters and cpf_set_parameters.
 *
 *  nml_file_path: C string containing path to nml file to initialize parameters from. Parameters not set by the nml
 *      file are initialized to default values.
 *  nlevels: pointer to number of pfasst levels. All parameters other than the number of levels are initialized to
 *      default values.
 */
void cpf_initialize_pfasst(char* nml_file_path, int* nlevels);

/*
 * Function:  cpf_initialize_level
 * --------------------
 * Allocate and initialize user levels and related structures. Must be called once for every pfasst level.
 *
 *  level_index: pointer to 1-based index of level to be initialized
 *  data_size: pointer to size in bytes of user-allocated data for this level (used for MPI communication)
 */
void cpf_initialize_level(int* level_index, int* data_size);

/*
 * Function:  cpf_set_initial_condition
 * --------------------
 * Set initial condition for run
 *
 *  data: pointer to the initial condition
 */
void cpf_set_initial_condition(user_encap_t** data);

/*
 * Function:  cpf_set_final_condition
 * --------------------
 * Set storage for final condition of run
 *
 *  data: pointer to allocated memory where the final condition shall be stored
 */
void cpf_set_final_condition(user_encap_t** data);

/*
 * Function:  cpf_run
 * --------------------
 * Trigger the main pfasst loop. Must be called with tend OR nstep (the unused parameter must be set to null).
 *
 *  dt: pointer to time step size
 *  tend: pointer to end time of the run
 *  nsteps: pointer to number of steps to run
 */
void cpf_run(double* dt, double* tend, int* nsteps);

/*
 * Function:  cpf_destroy
 * --------------------
 * Free Fortran-allocated memory for the run
 */
void cpf_destroy();

// Getters and setters for LibPFASST parameters
// https://libpfasst.github.io/LibPFASST/docs/build/html/parameters.html

void cpf_get_parameters(cpf_parameter_t** prm);
void cpf_set_parameters(cpf_parameter_t** prm);