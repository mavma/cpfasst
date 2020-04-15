#pragma once

void sweeper_f_eval_cb(void** y, double* t, int* level_index, void** f, int* piece);
void sweeper_f_comp_cb(void** y, double* t, double* dtq, void** rhs, int* level_index, void** f, int* piece);