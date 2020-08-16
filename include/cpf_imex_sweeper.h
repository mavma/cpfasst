/** @file cpf_imex_sweeper.h
 * C callback interface for LibPFASST's pf_imex_sweeper
 * Sweeper for equation of the form y(t)' = f_1(t,y) + f_2(t,y), where f_1 is treated explicitly and f_2 implicitly
 */

#pragma once

#include <stdbool.h>

/**
 * Initialize sweeper for one level
 * @param[in]  level_index Index (1-based) of the level
 * @param[out] explicit True if explicit part (f_1) is present
 * @param[out] implicit True if implicit part (f_2) is present
 */
void cpf_imex_sweeper_initialize_cb(int level_index, bool* explicit, bool* implicit);

/**
 * Destroy sweeper for one level
 * @param[in] level_index Index (1-based) of the level
 */
void cpf_imex_sweeper_destroy_cb(int level_index);

/**
 * Compute one piece of the RHS function
 * @param[in] y
 * @param[in] t
 * @param[in] level_index Index (1-based) of the level
 * @param[out] f
 * @param[in] piece Piece of RHS to calculate (1 or 2)
 */
void cpf_imex_sweeper_f_eval_cb(encap_data_t* y, double t, int level_index, encap_data_t* f, int piece);

/**
 * Solve the implicit equation y - dtq*f_2(y) = rhs, updating y and f_2
 * @param[in,out] y
 * @param[in] t
 * @param[in] dtq
 * @param[in] rhs
 * @param[in] level_index Index (1-based) of the level
 * @param[in,out] f f_2
 */
void cpf_imex_sweeper_f_comp_cb(encap_data_t* y, double t, double dtq, encap_data_t* rhs, int level_index, encap_data_t* f);