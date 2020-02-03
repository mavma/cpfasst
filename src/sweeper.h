#pragma once

void feval (double** y, int* ydim, double* t, int* level_index, double** f, int* fdim, int* piece);
void fcomp (double** y, int* ydim, double* t, double* dtq, double** rhs, int* rhsdim, int* level_index, double** f, int* fdim, int* piece);
