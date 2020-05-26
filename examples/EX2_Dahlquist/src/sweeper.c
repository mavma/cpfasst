#include "cpf_imex_sweeper.h"

#include <stdio.h>
#include <stdlib.h>
#include <assert.h>
#include "local.h"

void imex_sweeper_initialize_cb(int* level_index, bool* explicit, bool* implicit) {}
void imex_sweeper_destroy_cb(int* level_index) {}

void imex_sweeper_f_eval_cb(void** y, double* t, int* level_index, void** f, int* piece) {
    custom_data_t *cy = (custom_data_t*) (*y);
    custom_data_t *cf = (custom_data_t*) (*f);

    switch(*piece) {
        case 1: // Explicit piece
            cf->y = local_prm.lam1*cy->y;
            break;
        case 2: // Implicit piece
            cf->y = local_prm.lam2*cy->y;
            break;
        default:
            printf("Bad case for piece in f_eval: %d", *piece);
            exit(0);
            break;
    }
    return;
}

void imex_sweeper_f_comp_cb(void** y, double* t, double* dtq, void** rhs, int* level_index, void** f, int* piece) {
    custom_data_t *cy = (custom_data_t*) (*y);
    custom_data_t *cf = (custom_data_t*) (*f);
    custom_data_t *crhs = (custom_data_t*) (*rhs);

    switch(*piece) {
        case 2:
            cy->y = crhs->y/(1.0 - (*dtq)*local_prm.lam2);
            cf->y = (cy->y - crhs->y)/(*dtq);
            break;
        default:
            printf("Bad case for piece in f_comp: %d", *piece);
            exit(0);
            break;
    }
    return;
}