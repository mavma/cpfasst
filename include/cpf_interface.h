/** @file cpf_interface.h
 * C interfaces to mandatory cpfasst functions
 * Mandatory calls must occur in this order:
 * 1. MPI_Initialize
 * 2. cpf_initialize_from_* (choose one variant)
 * 3. for each level: cpf_initialize_level
 * 4. cpf_set_initial_condition
 * 5. cpf_set_solution_storage
 * 6. cpf_run
 * 7. cpf_destroy
 */

#pragma once

/**
 * Initializes LibPFASST with values from the provided nml file
 * @param[in] nml_file_path
 */
void cpf_initialize_from_nml(char nml_file_path[256]);

/**
 * Initializes LibPFASST with default values for a given number of levels
 * @param[in] nlevels
 */
void cpf_initialize_from_nlevels(int nlevels);

/**
 * Initializes one level and set its data size
 * Must be called once for every PFASST level
 * @param[in] level_index Index (1-based) of the level
 * @param[in] data_size Size in bytes of the user data associated with this level
 */
void cpf_initialize_level(int level_index, int data_size);

/**
 * Sets initial condition for the run
 * @param[in] data Initial condition
 */
void cpf_set_initial_condition(encap_data_t* data);

/**
 * Sets address where LibPFASST will store the final solution
 * @param[in] data Pre-allocated memory for solution storage
 */
void cpf_set_solution_storage(encap_data_t* data);

/**
 * Runs the main pfasst loop
 * @param[in] dt Step size
 * @param[in] nsteps Total number of steps
 */
void cpf_run(double dt, int nsteps);

/**
 * Frees memory allocated by LibPFASST
 */
void cpf_destroy();







