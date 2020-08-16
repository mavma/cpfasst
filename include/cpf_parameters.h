#pragma once

#include <stdbool.h>
#include "cpf_static.h"

typedef struct cpf_parameter_struct {
    // === Mandatory pfasst parameters (must be set during initialization, cannot be changed)  ===
    int nlevels;                    // number of pfasst levels

    //  ===  Optional pfasst parameters ====
    int niters;                     // number of PFASST iterations to do
    int qtype;                      // type of nodes
    bool use_proper_nodes;
    bool use_composite_nodes;
    bool use_no_left_q;

    // --  level dependent parameters
    int nsweeps[PF_MAXLEVS];        //  number of sweeps at each levels
    int nsweeps_pred[PF_MAXLEVS];   //  number of sweeps during predictor
    int nnodes[PF_MAXLEVS];         // number of nodes

    // --  tolerances
    double abs_res_tol;             //  absolute convergence tolerance
    double rel_res_tol;             //  relative convergence tolerance

    // --  predictor options  (should be set before pfasst_run is called)
    bool PFASST_pred;               //  true if the PFASST type predictor is used
    bool pipeline_pred;             //  true if coarse sweeps after burn in are pipelined  (if nsweeps_pred>1 on coarse level)
    int nsweeps_burn;               //  number of sdc sweeps to perform during coarse level burn in
    int q0_style;                   //  q0 can take 3 values
                                    //  0:  Only the q0 at t=0 is valid  (default)
                                    //  1:  The q0 at each processor is valid
                                    //  2:  q0 and all nodes at each processor is valid

    // --  run options  (should be set before pfasst_run is called)
    bool Vcycle;                    //  decides if Vcycles are done
    bool use_pysdc_V;               //  decides if Vcycles are done
    bool sweep_at_conv;             //  decides if one final sweep after convergence is done
    bool Finterp;                   //  True if transfer functions operate on rhs
    bool use_LUq;                   //  True if LU type implicit matrix is used
    bool use_Sform;                 //  True if Qmat type of stepping is used
    int taui0;                      // iteration cutoff for tau inclusion

    // -- RK and Parareal options
    bool use_sdc_sweeper;           // decides if SDC sweeper is used
    bool use_rk_stepper;            // decides if RK steps are used instead of the sweeps
    int nsteps_rk[PF_MAXLEVS];      // number of runge-kutta steps per time step
    bool RK_pred;                   //  true if the coarse level is initialized with Runge-Kutta instead of PFASST

    // -- misc
    bool debug;                     //  If true, debug diagnostics are printed

    // -- controller for the results
    bool save_residuals;            //  Will save residuals every time they are set
    bool save_delta_q0;             //  Will save change in initial condition
    bool save_errors;               //  Will save errors, but set_error must be called externally
    bool save_json;                 //  Will save a jason file of run parameters
    int save_timings;               //  0=none, 1=total only, 2=all, 3=all and echo
    char outdir[256];               //  Output directory
} cpf_parameter_t;

// Getters and setters for LibPFASST parameters, must be called using a pointer to an allocated cpf_parameter_t
// https://libpfasst.github.io/LibPFASST/docs/build/html/parameters.html
void cpf_get_parameters(cpf_parameter_t* prm);
void cpf_set_parameters(cpf_parameter_t* prm);