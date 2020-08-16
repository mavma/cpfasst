// Uses fftpack to provide needed functions for sweeper and level
// Based on LibPFASST/src/pf_fftpack.f90

#include "fft_tool.h"

#include <math.h>
#include <assert.h>
#include <fftpack.h>
#include "utils.h"
#include "shared.h"

// helper function for Fortran syntax y[y1:y2] = x[x1:x2] (complex)
void fvec_assign(complex double y[], int y1, int y2, complex double x[], int x1, int x2) {
    assert(y2-y1 == x2-x1);
    for(int i=0; i<(y2-y1+1); i++) {
        y[y1-1+i] = x[x1-1+i];
    }
}

void fft_setup(fft_tool_t *this, int nx, double Lx) {
    //  FFT Storage parameters
    this->nx = nx;
    this->lensavx = 4*this->nx + 15;
    this->normfact = this->nx;
    this->wsavex = (double*) malloc_and_check(this->lensavx*sizeof(double));
    this->Lx = Lx;

    // Initialize FFT
    cffti(this->nx, this->wsavex);

    this->wk_1d = (double complex*) malloc_and_check(this->nx*sizeof(double complex));

    // Assign wave numbers
    this->kx = (double*) malloc_and_check(this->nx*sizeof(double));
    double om = TWOPI/this->Lx;

    for(int i=0; i<this->nx; i++) {
        if(i+1 <= this->nx/2+1) {
            this->kx[i] = om*i;
        } else {
            this->kx[i] = om*(-this->nx+i);
        }
    }
}

void fft_destroy(fft_tool_t *this) {
    free(this->wsavex);
    free(this->wk_1d);
    free(this->kx);
}

void fftf(fft_tool_t *this) {
    cfftf(this->nx, (double*)this->wk_1d, this->wsavex);
    for(int i = 0; i < this->nx; i++) {
        this->wk_1d[i] = this->wk_1d[i] / this->normfact;
    }
}

void fftb(fft_tool_t *this) {
    cfftb(this->nx, (double*)this->wk_1d, this->wsavex);
}

void conv_1d(fft_tool_t *this, double* g, double complex *op, double* c) {
    for(int i = 0; i < this->nx; i++) {
        this->wk_1d[i] = g[i];
    }
    fftf(this);
    for(int i = 0; i < this->nx; i++) {
        this->wk_1d[i] *= op[i];
    }
    fftb(this);
    for(int i = 0; i < this->nx; i++) {
        c[i] = creal(this->wk_1d[i]);
    }
}

void make_lap_1d(fft_tool_t *this, double complex *lap) {
    for(int i = 0; i < this->nx; i++) {
        lap[i] = -(pow(this->kx[i],2));
    }
}

void make_deriv_1d(fft_tool_t *this, double complex *ddx) {
    for(int i = 0; i < this->nx; i++) {
        ddx[i] = (0.0+1.0*I)*this->kx[i];
    }
}

void zinterp_1d(double complex yhat_c[], int nx_c, double complex yhat_f[], int nx_f) {
    if(nx_f == nx_c){
        for(int i = 0; i < nx_f; i++) yhat_f[i] = yhat_c[i];
        return;
    }

    // yhat_f = 0.0_pfdp
    for(int i = 0; i < nx_f; i++) yhat_f[i] = 0 + 0*I;
    // yhat_f(1:nx_c/2) = yhat_c(1:nx_c/2)
    fvec_assign(yhat_f, 1, nx_c/2, yhat_c, 1, nx_c/2);
    // yhat_f(nx_f-nx_c/2+2:nx_f) = yhat_c(nx_c/2+2:nx_c)
    fvec_assign(yhat_f, nx_f-nx_c/2+2, nx_f, yhat_c, nx_c/2+2, nx_c);
}

void interp_1d(fft_tool_t *fft_c, double yvec_c[], fft_tool_t *fft_f, double yvec_f[]) {
    if(fft_c->nx == fft_f->nx) {
        for (int i = 0; i < fft_c->nx; i++) yvec_f[i] = yvec_c[i];
        return;
    }
    // wk_c=yvec_c
    for(int i = 0; i < fft_c->nx; i++) fft_c->wk_1d[i] = yvec_c[i];
    // call this%fftf()      !  internal forward fft call
    fftf(fft_c);
    // call this%zinterp_1d(wk_c, wk_f)
    zinterp_1d(fft_c->wk_1d, fft_c->nx, fft_f->wk_1d, fft_f->nx);
    // call fft_f%fftb()     !  internal inverse fft call
    fftb(fft_f);
    // yvec_f=REAL(wk_f,pfdp) !  grab the real part
    for(int i = 0; i < fft_f->nx; i++) yvec_f[i] = creal(fft_f->wk_1d[i]);
}