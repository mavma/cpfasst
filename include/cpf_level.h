# pragma once

// Restriction and interpolation callbacks
//   f_level_index, c_level_index: index of fine and coarse levels
//   f_data, c_data: pointers to data for fine and coarse levels
//   t: solution time
//   flags: unused
void level_interpolate_cb(int* f_level_index, int* c_level_index, void** f_data, void** c_data, double* t, int* flags);
void level_restrict_cb(int* f_level_index, int* c_level_index, void** f_data, void** c_data, double* t, int* flags);