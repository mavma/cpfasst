#pragma once

#include "cpf_parameters.h"

// Mandatory function calls for a cpfasst run (in this order):
//
// 0. MPI_Initialize(...)
// 1. cpf_initialize_...(...) -> allocate and initialize parameter structures
// 2. for each level: cpf_allocate_level(...) -> allocate and initialize levels
// 3. cpf_run_...(...) -> trigger pfasst main loop
// 4. cpf_destroy(...) -> free Fortran-allocated memory

// Initialize PFASST with values the provided nml file
void cpf_initialize_from_nml(char nml_file_path[256]);

// Initialize PFASST with default values for nlevels levels
void cpf_initialize_from_nlevels(int nlevels);

// Allocate and initialize user levels and related structures. Must be called once for every pfasst level.
void cpf_initialize_level(int level_index, int data_size);

// Run the main pfasst loop with step size dt for nsteps steps
void cpf_run(double dt, int nsteps);

// Free Fortran-allocated memory
void cpf_destroy();

// Set initial condition for run
void cpf_set_initial_condition(user_data_t* data);

// Set address for storage of solution
void cpf_set_solution_storage(user_data_t* data);

// Get pointer to current solution at given level
user_data_t* cpf_get_current_solution(int level_index);

// Get time at current endpoint
double cpf_get_endpoint_time();

