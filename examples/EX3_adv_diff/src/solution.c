// Calculates exact solution for the 1-D advection/diffusion example
// Based on LibPFASST/src/pf_solution.f90

#include "solution.h"

#include <assert.h>
#include <quadmath.h>
#include <math.h>
#include "shared.h"

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

// get exact solution at time t
void exact(double y[], int nx, double t) {
    assert(local_prm.ic_type == 1);
    exact_ad_cos_1ds(t, y, nx, local_prm.nu, local_prm.v, local_prm.kfreq, local_prm.Lx);
}