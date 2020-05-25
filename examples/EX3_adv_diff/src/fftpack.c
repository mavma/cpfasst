#include <complex.h>
#include <stdlib.h>
#include <quadmath.h>
#include <math.h>
#include <fftpack.h>

typedef struct fftpack_struct {
    int nx;
    int lensavx;
    double normfact;
    double complex *workhatx;
    double *wsavex;
    double Lx;
    double complex *wk_1d;
    double *kx;
} fftpack_t;

void fft_setup(fftpack_t *this, int grid_shape, double grid_size) {
    //  FFT Storage parameters
    this->nx = grid_shape;
    this->lensavx = 4*this->nx + 15;
    this->normfact = this->nx;

    this->workhatx = (double complex*) calloc(this->nx, sizeof(double complex));
    this->wsavex = (double*) calloc(this->lensavx, sizeof(double));
    if(this->workhatx == NULL || this->wsavex == NULL) exit(EXIT_FAILURE);

    this->Lx = grid_size;

    // Initialize FFT
    // call ZFFTI( nx, this%wsavex )
    cffti(this->nx, this->wsavex);

    this->wk_1d = (double complex*) calloc(this->nx, sizeof(double complex));
    if(this->wk_1d == NULL) exit(EXIT_FAILURE); // TODO: error msg

    // Assign wave numbers
    this->kx = (double*) calloc(this->nx, sizeof(double));
    if(this->kx == NULL) exit(EXIT_FAILURE); // TODO: error msg
    double twopi = (double) (M_PIq * 2.0Q);
    double om = twopi/this->Lx;

    for(int i=0; i<this->nx; i++) {
        if(i+1 <= this->nx/2+1) this->kx[i] = om*i;
        else this->kx[i] = om*(-this->nx+i);
    }
}

void fft_destroy(fftpack_t *this) {
    free(this->workhatx);
    free(this->wsavex);
    free(this->wk_1d);
    free(this->kx);
}

void fftf(fftpack_t *this) {
    cfftf(this->nx, (double*)this->wk_1d, this->wsavex);
    for(int i = 0; i < this->nx; i++) this->wk_1d[i] = this->wk_1d[i] / this->normfact;
}

void fftb(fftpack_t *this) {
    cfftb(this->nx, (double*)this->wk_1d, this->wsavex);
}

void conv_1d(fftpack_t *this, double* g, double complex *op, double* c) {
    for(int i = 0; i < this->nx; i++) this->wk_1d[i] = g[i];
    fftf(this);
    for(int i = 0; i < this->nx; i++) this->wk_1d[i] *= op[i];
    fftb(this);
    for(int i = 0; i < this->nx; i++) c[i] = creal(this->wk_1d[i]);
}

void make_lap_1d(fftpack_t *this, double complex *lap) {
    for(int i = 0; i < this->nx; i++) lap[i] = -(pow(this->kx[i],2));
}

void make_deriv_1d(fftpack_t *this, double complex *ddx) {
    for(int i = 0; i < this->nx; i++) ddx[i] = (0.0+1.0*I)*this->kx[i];
}