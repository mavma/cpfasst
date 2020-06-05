#include "cpf_level.h"

#include <string.h>
#include "local.h"

void level_interpolate_cb(int* f_level_index, int* c_level_index, void** f_data, void** c_data, double* t, int* flags) {
    memcpy(*f_data, *c_data, sizeof(custom_data_t));
}
void level_restrict_cb(int* f_level_index, int* c_level_index, void** f_data, void** c_data, double* t, int* flags) {
    memcpy(*c_data, *f_data, sizeof(custom_data_t));
}