#pragma once

#include <stdbool.h>
#include "cpf_static.h"

// Sweeper for equation of the form y' = f_1(y) + f_2(y), where f_1 is treated explicitly and f_2 implicitly

// Initialize sweeper for this level
//      explicit: set to true if f_1 is present
//      implicit: set to true if f_2 is present
void cpf_imex_sweeper_initialize_cb(int level_index, bool* explicit, bool* implicit);

// Destroy sweeper for this level
void cpf_imex_sweeper_destroy_cb(int level_index);

// Compute the RHS function value f_piece(y)
void cpf_imex_sweeper_f_eval_cb(user_data_t* y, double t, int level_index, user_data_t* f, int piece);

// Solve the implicit equation y - dtq*f_2(y) = rhs
void cpf_imex_sweeper_f_comp_cb(user_data_t* y, double t, double dtq, user_data_t* rhs, int level_index, user_data_t* f);