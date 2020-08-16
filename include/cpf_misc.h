/** @file cpf_misc.h
 * C interfaces to miscellaneous LibPFASST functions
 * Interfaces to functions implemented in cpf_interface.f90 to enable minor aspects of the cpfasst examples.
 * Ideally, these should eventually be migrated to the interfaces of the classes they access.
 */

/**
 * Get pointer to current solution at given level
 * @param[in]  level_index Index (1-based) of the level
 */
encap_data_t* cpf_get_current_solution(int level_index);

/**
 * Get time at current endpoint
 */
double cpf_get_endpoint_time();

/**
 * Set the error value for a level at the current run state
 * @param[in] level_index Index (1-based) of the level
 * @param[in] error
 */
void cpf_set_error(int level_index, double error);