#include "types.h"
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <mpi.h>
#include <cpf_interface.h>
#include <cpf_imex_sweeper.h>
#include <cpf_parameters.h>
#include <cpf_hooks.h>
#include "utils.h"
#include "shared.h"
#include "probin.h"
#include "solution.h"
#include "encap.h"

// compute error of current solution, then set it on LibPFASST for output
void update_error(void* pf, int* level_index) {
    double t = cpf_get_endpoint_time();
    ex3_data_t *current = cpf_get_current_solution(*level_index);
    double error = compute_error(current, t);
    cpf_set_error(*level_index, error);
}

int main(int argc, char** argv) {

    char input_nml[256];

    // initialize MPI
    MPI_Init(&argc, &argv);

    // parse input nml file from command line
    if (argc == 2) {
        strcpy(input_nml, argv[1]);
        printf("Reading parameters from %s\n", input_nml);
    } else {
        printf("Usage: %s input_nml", argv[0]);
        exit(EXIT_FAILURE);
    }

    // load local parameters from nml file
    load_local_parameters(input_nml);

    // initialize libpfasst parameters from nml file
    cpf_initialize_from_nml(ex3_prm.pfasst_nml);

    // get libpfasst parameters
    cpf_parameter_t pf_prm;
    cpf_get_parameters(&pf_prm);
    // standardize output folder name for testing
    int np; MPI_Comm_size(MPI_COMM_WORLD, &np);
    sprintf(pf_prm.outdir, "outdirP%04d", np);
    cpf_set_parameters(&pf_prm);

    // initialize levels
    for(int l=0; l<pf_prm.nlevels; l++) {
        int level_index = l + 1; // 1-based index
        int data_size = ex3_data_get_size(ex3_prm.nx[l]);
        cpf_initialize_level(level_index, data_size);
    }

    // set the initial condition
    int finest_nx = ex3_prm.nx[pf_prm.nlevels-1];
    ex3_data_t *ic = ex3_data_create(finest_nx);
    compute_exact_solution(ic, 0.0);
    cpf_set_initial_condition(ic);

    // set pointer for the final solution
    ex3_data_t *solution = ex3_data_create(finest_nx);
    cpf_set_solution_storage(solution);

    // hook to set the error for LibPFASST output
    cpf_add_custom_hook(-1, PF_POST_SWEEP, &update_error);

    // start the pfasst run
    cpf_run(ex3_prm.dt, ex3_prm.nsteps);

    // free LibPFASST and local memory
    cpf_destroy();
    ex3_data_destroy(ic);
    ex3_data_destroy(solution);

    printf("Run complete\n");

    // wait for all processors to be done, then finalize MPI
    MPI_Barrier(MPI_COMM_WORLD);
    MPI_Finalize();
}

