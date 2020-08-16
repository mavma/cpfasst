// User-defined types
#pragma once

#include <stddef.h>
#include <cpf_static.h>
#include "fft_tool.h"

// user-defined data structure for 1D array
typedef struct ex3_data_struct {
    size_t nx;
    double arr[]; // size nx
} ex3_data_t;

typedef ex3_data_t user_data_t;

// data for each level sweeper
typedef struct ex3_sweeper_struct {
    fft_tool_t* fft_tool;
    complex double *opE;    // explicit spectral operator
    complex double *opI;    // implicit spectral operator
    complex double *tmp;    // temp array used in f_comp
} ex3_sweeper_t;

// problem-specific parameters and run parameters
typedef struct ex3_prm_struct {
    double v;               // advection velocity
    double nu;              // viscosity
    double kfreq;           // initial condition parameter
    double dt;              // time step
    double Tfin;            // final time
    double Lx;              // domain size
    int nx[PF_MAXLEVS];     // number of grid points for each level
    int nsteps;             // number of time steps
    int imex_stat;          // type of imex splitting: explicit(0), implicit(1) or imex(2)
    int ic_type;            // initial condition type
    char pfasst_nml[256];   // file for reading pfasst parameters
} ex3_prm_t;