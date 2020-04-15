#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <mpi.h>

#include "cpf_interface.h"
#include "cpf_sweeper.h"
#include "data.h"

char fname[256] = "probin.nml";

void run_pfasst();

int main(int argc, char** argv) {

    // parse fname from command line
    if (argc == 2) {
        strcpy(fname, argv[1]);
        //printf("Reading parameters from %s\n", fname);
    } else if (argc != 1) {
        printf("Invalid command line parameters\n");
        exit(1);
    }

    MPI_Init(&argc, &argv);

    int nproc;
    MPI_Comm_size(MPI_COMM_WORLD, &nproc);

    run_pfasst();

    MPI_Finalize();
}

void run_pfasst() {

    set_fname(fname);

    // !> Read problem parameters
    cpf_probin_init();

    // !>  Set up communicator
    cpf_mpi_create();

    // !>  Create the pfasst structure
    cpf_pfasst_create();

    // !> Loop over levels and set some level specific parameters
    size_t data_size = sizeof(custom_data_t);
    cpf_user_obj_allocate(&data_size);

    // !>  Set up some pfasst stuff
    cpf_pfasst_setup();

    // !> add some hooks for output  (using a LibPFASST hook here)
    cpf_add_hook();

    // !>  Output run parameters to screen
    cpf_print_loc_options();
    
    // !>  Allocate initial condition
    // !> Set the initial condition
    cpf_setup_ic();

    // set sweeper functions
    // cpf_imex_sweeper_set_feval(&feval);
    // cpf_imex_sweeper_set_fcomp(&fcomp);

    // !> Do the PFASST time stepping
    cpf_pfasst_run();
    
    // !>  Wait for everyone to be done
    // call mpi_barrier(pf%comm%comm, ierror)
    MPI_Barrier(MPI_COMM_WORLD);

    // !>  Deallocate initial condition and final solution
    cpf_cleanup();
}