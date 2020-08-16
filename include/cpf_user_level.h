/** @file cpf_user_level.h
 * C callback interface for cpf_user_level_t
 */

# pragma once

/**
 * Interpolate between spatial discretization levels
 * @param[in]  f_level_index Index (1-based) of the fine level
 * @param[in]  c_level_index Index (1-based) of the coarse level
 * @param[out] f_data Solution at fine level
 * @param[in]  c_data Solution at coarse level
 * @param[in]  t Current time
 */
void cpf_user_level_interpolate_cb(int f_level_index, int c_level_index, encap_data_t* f_data, encap_data_t* c_data, double t);

/**
 * Restrict between spatial discretization levels
 * @param[in]  f_level_index Index (1-based) of the fine level
 * @param[in]  c_level_index Index (1-based) of the coarse level
 * @param[in]  f_data Solution at fine level
 * @param[out] c_data Solution at coarse level
 * @param[in]  t Current time
 */
void cpf_user_level_restrict_cb(int f_level_index, int c_level_index, encap_data_t* f_data, encap_data_t* c_data, double t);