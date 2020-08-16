#include "types.h"
#include <cpf_imex_sweeper.h>
#include <stdio.h>
#include <stdlib.h>
#include "shared.h"

void cpf_imex_sweeper_initialize_cb(int level_index, bool* explicit, bool* implicit) {
    *explicit = true;
    *implicit = true;
}
void cpf_imex_sweeper_destroy_cb(int level_index) {}

void cpf_imex_sweeper_f_eval_cb(encap_data_t* y, double t, int level_index, encap_data_t* f, int piece) {
    switch(piece) {
        case 1: // Explicit piece
            f->val = ex2_prm.lam1 * y->val;
            break;
        case 2: // Implicit piece
            f->val = ex2_prm.lam1 * y->val;
            break;
        default:
            printf("Bad case for piece in f_eval: %d", piece);
            exit(0);
            break;
    }
}

void cpf_imex_sweeper_f_comp_cb(encap_data_t* y, double t, double dtq, encap_data_t* rhs, int level_index, encap_data_t* f) {
    y->val = rhs->val / (1.0 - dtq * ex2_prm.lam2);
    f->val = (y->val - rhs->val)/dtq;
}