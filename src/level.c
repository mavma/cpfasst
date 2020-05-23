#include "cpf_level.h"

#include <string.h>
#include "data.h"

void level_interpolate_cb(void** f_lev, void** c_lev, void** f_vec, void** c_vec, double* t, int* flags) {
    memcpy(*f_vec, *c_vec, sizeof(custom_data_t));
}
void level_restrict_cb(void** f_lev, void** c_lev, void** f_vec, void** c_vec, double* t, int* flags){
    memcpy(*c_vec, *f_vec, sizeof(custom_data_t));
}