#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <mpi.h>

#include "cpf_interface.h"
//#include "cpf_imex_sweeper.h"

#include "local.h"
//#include "hooks.h" // TODO: remove?
#include "probin.h"

local_prm_t local_prm;
char fname[256] = "probin.nml";

void run_pfasst() {
    load_local_parameters(fname);
    // !>  Set up communicator
    cpf_mpi_create();
    // !>  Create the pfasst structure
    cpf_pfasst_create(local_prm.pfasst_nml);
//    // !> Loop over levels and set some level specific parameters
//    size_t data_size = sizeof(custom_data_t);
//    cpf_user_obj_allocate(&data_size);
//    // !>  Set up some pfasst stuff
//    cpf_pfasst_setup();
//
//    // !> add a hook for output
//    int level = -1;
//    cpf_hooks_t hook = PF_POST_ITERATION;
//    cpf_add_echo_residual_hook(&level, &hook);
//    // void(*cb)(void*,int*) = &my_custom_hook;
//    // cpf_add_custom_hook(&level, &hook, &cb);
//
//    // !> Allocate initial condition
//    // !> Set the initial condition
//    cpf_setup_ic();
//    // !> Do the PFASST time stepping
//    cpf_pfasst_run(&local_prm.dt, NULL, &local_prm.nsteps);
//    // !>  Wait for everyone to be done
//    MPI_Barrier(MPI_COMM_WORLD);
//    // !>  Deallocate initial condition and final solution
//    cpf_cleanup();
}

int main(int argc, char** argv) {
    // parse fname from command line
    if (argc == 2) {
        strcpy(fname, argv[1]);
        printf("Reading parameters from %s\n", fname);
    } else if (argc != 1) {
        printf("Invalid command line parameters\n");
        exit(1);
    }

    MPI_Init(&argc, &argv);
    run_pfasst();
    MPI_Finalize();
}
