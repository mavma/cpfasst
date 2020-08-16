/** @file cpf_imex_sweeper.h
 * Callback interface for cpf_encap_t
 */
#pragma once

/**
 * Allocate encapsulated data for one level
 * @param[in]  level_index Index (1-based) of the level
 * @param[out] data Pointer to allocated data
 */
void cpf_factory_create_cb(encap_data_t** data, int level_index);

/**
 * Deallocate encapsulated data
 * @param[in] data
 */
void cpf_factory_destroy_cb(encap_data_t* data);


/**
 * Set encapsulated data to value
 * @param[out] data
 * @param[in]  value
 */
void cpf_encap_setval_cb(encap_data_t* data, double value);

/**
 * Copy encapsulated data
 * @param[out] dst Destination
 * @param[in]  src Source
 */
void cpf_encap_copy_cb(encap_data_t* dst, encap_data_t* src);

/**
 * Compute norm of encapsulated data
 * @param[in] data
 * @return Computed norm
 */
double cpf_encap_norm_cb(encap_data_t* data);

/**
 * Compute y=a*x+y
 * @param[in,out] y
 * @param[in]     a
 * @param[in]     x
 */
void cpf_encap_axpy_cb(encap_data_t* y, double a, encap_data_t* x);

/**
 * Print data to standard output for debugging purposes
 * @param[in] data
 */
void cpf_encap_eprint_cb(encap_data_t* data);