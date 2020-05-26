#pragma once

typedef struct custom_data_struct {
    double y;
} custom_data_t;

typedef struct local_prm_struct {
    double lam1;
    double lam2;
    double dt;              // time step
    double Tfin;            // final time
    int nsteps;             // number of time steps
    char pfasst_nml[128];   // file for reading pfasst parameters
} local_prm_t;

extern local_prm_t local_prm;