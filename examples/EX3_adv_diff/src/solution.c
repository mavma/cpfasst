// Calculates exact solution for the 1-D advection/diffusion example
// Based on LibPFASST/src/pf_solution.f90

#include "solution.h"

#include <assert.h>
#include <quadmath.h>
#include <math.h>
#include "shared.h"
#include "encap.h"

double ad_cos_ex(double t, double x, double nu, double v, double kfreq, double Lx) {
    double u, omega;
    double twopi = (double) (M_PIq * 2.0Q);
    omega = kfreq * twopi / Lx;
    u = cos(omega * (x-t*v)) * exp(-omega*omega*nu*t);
    return u;
}

void exact_ad_cos_1ds(double t, double y[], int nx, double nu, double v, double kfreq, double Lx) {
    for(int i=0; i<nx; i++) {
        double x = Lx*((double) i)/nx;
        y[i] = ad_cos_ex(t, x, nu, v, kfreq, Lx);
    }
}

// compute exact solution at time t
void compute_exact_solution(ex3_data_t* y, double t) {
    assert(ex3_prm.ic_type == 1);
    exact_ad_cos_1ds(t, y->array, y->nx, ex3_prm.nu, ex3_prm.v, ex3_prm.kfreq, ex3_prm.Lx);
}

// compute error for given solution at time t
double compute_error(ex3_data_t* y, double t) {
    assert(ex3_prm.ic_type == 1);
    ex3_data_t* exact = ex3_data_create(y->nx);
    compute_exact_solution(exact, t);
    double max = 0;
    for(int i = 0; i < y->nx; i++) {
        double abs = fabs(y->array[i] - exact->array[i]);
        max = (abs > max) ? abs : max;
    }
    return(max);
}