#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <mpi.h>

#include <cpf_interface.h>
#include <cpf_imex_sweeper.h>
#include "utils.h"

#include "shared.h"
#include "probin.h"
#include "solution.h"

char fname[256] = "probin.nml";

void setup_initial_condition_cb(void** data) {
    *data = malloc(sizeof(my_data_t));
    my_data_t *data_ = (my_data_t*) (*data);
    // FIXME: get the configured number of levels from pfasst
    int max = 0;
    for(int i=0; i<PF_MAXLEVS; i++) max = (local_prm.nx[i] > max) ? local_prm.nx[i] : max;
    data_->size = max;
    data_->array = (double*) calloc_and_check(data_->size, sizeof(double));
    // setup initial condition
    exact(data_->array, data_->size, 0.0);
}

void setup_final_condition_cb(void** data) {
    *data = malloc(sizeof(my_data_t));
    my_data_t *data_ = (my_data_t*) (*data);
    // FIXME: get the configured number of levels from pfasst
    int max = 0;
    for(int i=0; i<PF_MAXLEVS; i++) max = (local_prm.nx[i] > max) ? local_prm.nx[i] : max;
    data_->size = max;
    data_->array = (double*) calloc_and_check(data_->size, sizeof(double));
}

void run_pfasst() {
    load_local_parameters(fname);
    // !>  Set up communicator
    cpf_mpi_create();
    // !>  Create the pfasst structure
    cpf_pfasst_create(local_prm.pfasst_nml);
    // !> Loop over levels and set some level specific parameters
    size_t data_size = 512*sizeof(double); //FIXME
    cpf_user_obj_allocate(&data_size);
    // !>  Set up some pfasst stuff
    cpf_pfasst_setup();

    // !> add a hook for output
    int level = -1;
    cpf_hooks_t hook = PF_POST_ITERATION;
    cpf_add_echo_residual_hook(&level, &hook);

    // !> Allocate initial condition
    // !> Set the initial condition
    cpf_setup_ic();
    // !> Do the PFASST time stepping
    cpf_pfasst_run(&local_prm.dt, NULL, &local_prm.nsteps);
    // !>  Wait for everyone to be done
    MPI_Barrier(MPI_COMM_WORLD);
    // !>  Deallocate initial condition and final solution
    cpf_cleanup();
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

