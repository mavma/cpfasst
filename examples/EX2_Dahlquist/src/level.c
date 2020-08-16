#include "types.h"
#include <cpf_user_level.h>
#include <string.h>
#include "shared.h"

void cpf_user_level_interpolate_cb(int f_level_index, int c_level_index, encap_data_t* f_data, encap_data_t* c_data, double t) {
    memcpy(f_data, c_data, sizeof(ex2_data_t));
}

void cpf_user_level_restrict_cb(int f_level_index, int c_level_index, encap_data_t* f_data, encap_data_t* c_data, double t) {
    memcpy(c_data, f_data, sizeof(ex2_data_t));
}