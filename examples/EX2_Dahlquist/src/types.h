#pragma once

// user-defined data structure for scalar
typedef struct ex2_data_struct {
    double y;
} ex2_data_t;

typedef ex2_data_t encap_data_t;

// problem-specific parameters and run parameters
typedef struct local_prm_struct {
    double lam1;            // lambda for explicit piece
    double lam2;            // lambda for implicit piece
    double dt;              // time step
    double Tfin;            // final time
    int nsteps;             // number of time steps
    char pfasst_nml[256];   // file for reading pfasst parameters
} ex2_prm_t;