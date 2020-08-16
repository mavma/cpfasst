#include "types.h"
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <mpi.h>
#include <cpf_interface.h>
#include <cpf_parameters.h>
#include "probin.h"

ex2_prm_t ex2_prm;
char fname[256] = "probin.nml";

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

    // initialize LibPFASST parameters from nml file
    cpf_initialize_from_nml(ex2_prm.pfasst_nml);

    // get libpfasst parameters
    cpf_parameter_t pf_prm;
    cpf_get_parameters(&pf_prm);

    // initialize levels
    for(int l=0; l < pf_prm.nlevels; l++) {
        int level_index = l + 1; // 1-based index
        int data_size = sizeof(ex2_data_t);
        cpf_initialize_level(level_index, data_size);
    }

    // set the initial condition
    ex2_data_t ic = { 1.0 };
    cpf_set_initial_condition(&ic);

    // set pointer for the final solution
    ex2_data_t solution;
    cpf_set_solution_storage(&solution);

    // start the pfasst run
    cpf_run(ex2_prm.dt, ex2_prm.nsteps);

    // free LibPFASST-allocated memory
    cpf_destroy();

    // wait for all processors to be done, then finalize MPI
    MPI_Barrier(MPI_COMM_WORLD);
    MPI_Finalize();
}

