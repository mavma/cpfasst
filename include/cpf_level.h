# pragma once

// Restriction and interpolation callbacks
//   f_lev, c_lev: unused
//   f_vec, c_vec: pointers to data for fine and coarse levels
//   t: solution time
//   flags: unused
void level_interpolate_cb(void** f_lev, void** c_lev, void** f_vec, void** c_vec, double* t, int* flags);
void level_restrict_cb(void** f_lev, void** c_lev, void** f_vec, void** c_vec, double* t, int* flags);