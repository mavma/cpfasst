#include "cpf_encap.h"

#include <stdio.h>
#include <stdlib.h>

void factory_create_cb(void** data, int* level_index, int** lev_shape, int* lev_shape_len) {
    //printf("Create called\n");
    *data = malloc(42);
}

void factory_destroy_cb(void** data) {
    //printf("Destroy called\n");
    free(*data);
}
