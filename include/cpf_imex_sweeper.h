#pragma once

#include <stdbool.h>

void imex_sweeper_initialize_cb(int* level_index, bool* explicit, bool* implicit);
void imex_sweeper_destroy_cb(int* level_index);
void imex_sweeper_f_eval_cb(void** y, double* t, int* level_index, void** f, int* piece);
void imex_sweeper_f_comp_cb(void** y, double* t, double* dtq, void** rhs, int* level_index, void** f, int* piece);