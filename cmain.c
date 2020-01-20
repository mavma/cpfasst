//http://www.yolinux.com/TUTORIALS/LinuxTutorialMixingFortranAndC.html
//https://northstar-www.dartmouth.edu/doc/solaris-forte/manuals/fortran/prog_guide/11_cfort.html
//https://gcc.gnu.org/onlinedocs/gcc-8.2.0/gfortran/Interoperability-with-C.html
//http://fortranwiki.org/fortran/show/Generating+C+Interfaces
//http://www.swig.org/ (C to other languages)
//https://gcc.gnu.org/onlinedocs/gcc-4.9.4/gfortran/Working-with-Pointers.html

#include <stdio.h>
#include <stdlib.h>
#include <stdint.h>
#include <stdbool.h>
#include <mpi.h>
#include <assert.h>

void cpf_probin_init();
void cpf_mpi_create();
void cpf_pfasst_create();
void cpf_user_obj_allocate();
void cpf_pfasst_setup();
void cpf_add_hook();
void cpf_print_loc_options();
void cpf_setup_ic();
void cpf_pfasst_run();
void cpf_cleanup();
void cpf_imex_sweeper_set_feval(void*);

// FIXME from probin
double lam1 =  1.0;
double lam2 = -2.0;

void feval (double* y, int ydim, double t, int level_index, double* f, int fdim, int piece) {

    assert(fdim == ydim);
    y[0] = 42;
    f[0] = 1138;
    /*switch(piece) {
        case 1: // ! Explicit piece
            for(int i=0; i<fdim; i++) f[i] = lam1*y[i];
            break;
        case 2: // ! Implicit piece
            for(int i=0; i<fdim; i++) f[i] = lam2*y[i];
            break;
        default:
            printf("Bad case for piece in f_eval %d", piece);
            exit(0);
            break;
    }*/
    return;
}

void run_pfasst();

int main(int argc, char** argv) {

    MPI_Init(&argc, &argv);

    int nproc;
    MPI_Comm_size(MPI_COMM_WORLD, &nproc);

    printf("Starting C main with %d processors\n", nproc);

    run_pfasst();

    MPI_Finalize();

    printf("Finishing C main\n");
}

void run_pfasst() {

    char pf_fname[256];

    // !> Read problem parameters
    printf("call probin_init(pf_fname)\n");
    cpf_probin_init();

    // !>  Set up communicator
    printf("call pf_mpi_create(comm, MPI_COMM_WORLD)\n");
    //MPI_Fint mpi_comm = MPI_Comm_c2f(MPI_COMM_WORLD); // https://www.mpi-forum.org/docs/mpi-2.2/mpi22-report/node361.htm
    //cpf_mpi_create((int*) &mpi_comm)
    cpf_mpi_create();

    // !>  Create the pfasst structure
    printf("call pf_pfasst_create(pf, comm, fname=pf_fname)\n");
    cpf_pfasst_create();

    // !> Loop over levels and set some level specific parameters
    printf("do l = 1, pf%%nlevels ...\n");
    cpf_user_obj_allocate();

    // !>  Set up some pfasst stuff
    printf("call pf_pfasst_setup(pf)");
    cpf_pfasst_setup();

    // !> add some hooks for output  (using a LibPFASST hook here)
    printf("call pf_add_hook(pf, -1, PF_POST_ITERATION, pf_echo_residual)\n");
    cpf_add_hook();

    // !>  Output run parameters to screen
    printf("call print_loc_options(pf,un_opt=6)\n");
    cpf_print_loc_options();
    
    // !>  Allocate initial condition
    printf("call ndarray_build(y_0, [ 1 ])\n");
    // !> Set the initial condition 
    printf("call y_0%%setval(1.0_pfdp)\n");
    cpf_setup_ic();

    // set sweeper functions
    cpf_imex_sweeper_set_feval(&feval);

    // !> Do the PFASST time stepping
    printf("call pf_pfasst_run(pf, y_0, dt, 0.0_pfdp, nsteps)\n");
    cpf_pfasst_run();
    
    // !>  Wait for everyone to be done
    // call mpi_barrier(pf%comm%comm, ierror)
    MPI_Barrier(MPI_COMM_WORLD);

    // !>  Deallocate initial condition and final solution
    cpf_cleanup();
}