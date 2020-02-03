#include "sweeper.h"

#include <stdio.h>
#include <stdlib.h>
#include <assert.h>

// FIXME: from probin
const double lam1 =  1.0;
const double lam2 = -2.0;

void feval (double** y, int* ydim, double* t, int* level_index, double** f, int* fdim, int* piece) {
    assert(*fdim == *ydim);
    switch(*piece) {
        case 1: // ! Explicit piece
            for(int i=0; i<*fdim; i++) (*f)[i] = lam1*(*y)[i];
            break;
        case 2: // ! Implicit piece
            for(int i=0; i<*fdim; i++) (*f)[i] = lam2*(*y)[i];
            break;
        default:
            printf("Bad case for piece in f_eval %d", *piece);
            exit(0);
            break;
    }
    return;
}

void fcomp (double** y, int* ydim, double* t, double* dtq, double** rhs, int* rhsdim, int* level_index, double** f, int* fdim, int* piece) {
    assert(*fdim == *ydim);
    assert(*fdim == *rhsdim);
    switch(*piece) {
        case 2:
            for(int i=0; i<*fdim; i++) {
                (*y)[i] = (*rhs)[i]/(1.0 - (*dtq)*lam2);
                (*f)[i] = ((*y)[i] - (*rhs)[i])/(*dtq);
            }
            break;
        default:
            printf("Bad case for piece in f_comp %d", *piece);
            exit(0);
            break;
    }
    return;
}