# pragma once

# include "cpf_static.h"

// Multilevel restriction and interpolation callbacks
//   f_level_index, *f_data: index and data of fine level
//   c_level_index, *c_data: index and data of coarse level
//   t: time
void cpf_level_interpolate_cb(int f_level_index, int c_level_index, encap_data_t* f_data, encap_data_t* c_data, double t);
void cpf_level_restrict_cb(int f_level_index, int c_level_index, encap_data_t* f_data, encap_data_t* c_data, double t);