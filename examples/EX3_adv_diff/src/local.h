#pragma once

#include <cpf_static.h>
#include "fft_tool.h"

// 1D array
typedef struct custom_data_struct {
    double *array;
    size_t size;
} custom_data_t;

typedef struct local_prm_struct {
    double v;               // advection velocity
    double nu;              // viscosity
    double kfreq;           // initial condition parameter
    double dt;              // time step
    double Tfin;            // final time
    double Lx;              // domain size
    int nx[PF_MAXLEVS];     // number of grid points
    int nsteps;             // number of time steps
    int imex_stat;          // type of imex splitting
    int ic_type;            // specifies the initial condition
    char pfasst_nml[128];   // file for reading pfasst parameters
} local_prm_t;

typedef struct my_sweeper_struct {
    fft_tool_t* fft_tool;
    complex double *opE;    // Explicit spectral operator
    complex double *opI;    // Implicit spectral operator
} my_sweeper_t;

extern local_prm_t local_prm;
extern my_sweeper_t *sweepers[PF_MAXLEVS];