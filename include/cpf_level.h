# pragma once

// Restriction and interpolation callbacks
//   f_lev_idx, c_lev_idx: index of fine and coarse levels
//   f_vec, c_vec: pointers to data for fine and coarse levels
//   t: solution time
//   flags: unused
void level_interpolate_cb(int* f_lev_idx, int* c_lev_idx, void** f_vec, void** c_vec, double* t, int* flags);
void level_restrict_cb(int* f_lev_idx, int* c_lev_idx, void** f_vec, void** c_vec, double* t, int* flags);