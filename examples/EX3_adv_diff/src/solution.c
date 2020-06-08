// Calculates exact solution for the 1-D advection/diffusion example
// Based on LibPFASST/src/pf_solution.f90

#include "solution.h"

#include <stdlib.h>
#include <assert.h>
#include <math.h>
#include "shared.h"
#include "encap.h"

double ad_cos_ex(double t, double x, double nu, double v, double kfreq, double Lx) {
    double u, omega;
    omega = kfreq * TWOPI / Lx;
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
void compute_exact_solution(user_data_t* y, double t) {
    assert(ex3_prm.ic_type == 1);
    exact_ad_cos_1ds(t, y->arr, y->nx, ex3_prm.nu, ex3_prm.v, ex3_prm.kfreq, ex3_prm.Lx);
}

// compute error for given solution at time t
double compute_error(user_data_t* y, double t) {
    assert(ex3_prm.ic_type == 1);
    user_data_t* exact = ex3_data_create(y->nx);
    compute_exact_solution(exact, t);
    double max = 0;
    for(int i = 0; i < y->nx; i++) {
        double abs = fabs(y->arr[i] - exact->arr[i]);
        max = (abs > max) ? abs : max;
    }
    ex3_data_destroy(exact);
    return max;
}