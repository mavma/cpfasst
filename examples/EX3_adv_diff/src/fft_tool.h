#pragma once

#include <complex.h>

typedef struct fft_tool_struct {
    int nx;
    int lensavx;
    double normfact;
    double *wsavex;             // size = lensavx
    double Lx;
    double complex *wk_1d;      // size = nx
    double *kx;                 // size = nx
} fft_tool_t;

void fft_setup(fft_tool_t *this, int nx, double Lx);

void fft_destroy(fft_tool_t *this);

void conv_1d(fft_tool_t *this, double* g, double complex *op, double* c) ;

void make_lap_1d(fft_tool_t *this, double complex *lap);

void make_deriv_1d(fft_tool_t *this, double complex *ddx);

void interp_1d(fft_tool_t *fft_c, double yvec_c[], fft_tool_t *fft_f, double yvec_f[]);