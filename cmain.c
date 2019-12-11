//http://www.yolinux.com/TUTORIALS/LinuxTutorialMixingFortranAndC.html
//https://northstar-www.dartmouth.edu/doc/solaris-forte/manuals/fortran/prog_guide/11_cfort.html
//https://gcc.gnu.org/onlinedocs/gcc-8.2.0/gfortran/Interoperability-with-C.html
//http://fortranwiki.org/fortran/show/Generating+C+Interfaces
//http://www.swig.org/ (C to other languages)
//https://gcc.gnu.org/onlinedocs/gcc-4.9.4/gfortran/Working-with-Pointers.html

#include <stdio.h>
#include <stdint.h>
#include <stdbool.h>
#include <mpi.h>

// extern "C"
// {
//     //          ,-- 2 Leading underscores to start
//     //          | ,-- then the module name
//     //          | |     ,-- then _MOD_
//     //          | |     |    ,-- then the subroutine name
//     //          V V     V    V
//     extern void __rocker_MOD_bye_baby();
// }

// TODO: handle type conversion from fortran with typedefs for readability
void cpf_probin_init();
void cpf_mpi_create(int*);
void cpf_pfasst_create();
void cpf_user_obj_allocate();
void cpf_pfasst_setup();

void run_pfasst();

int main(int argc, char** argv) {

    printf("Starting C main\n");

    MPI_Init(&argc, &argv);

    run_pfasst();

    MPI_Finalize();

    printf("Finishing C main\n");
}

void run_pfasst() {

    char pf_fname[256];

    // !> Read problem parameters
    //printf("call probin_init(pf_fname)\n");
    cpf_probin_init();

    // !>  Set up communicator
    printf("call pf_mpi_create(comm, MPI_COMM_WORLD)\n");
    MPI_Fint mpi_comm = MPI_Comm_c2f(MPI_COMM_WORLD); // https://www.mpi-forum.org/docs/mpi-2.2/mpi22-report/node361.htm
    printf("%i\n", sizeof(mpi_comm));
    printf("%i\n", sizeof(MPI_COMM_WORLD));
    printf("%i %i\n", mpi_comm, MPI_COMM_WORLD);
    cpf_mpi_create((int*) &mpi_comm);

    // !>  Create the pfasst structure
    printf("call pf_pfasst_create(pf, comm, fname=pf_fname)\n");
    cpf_pfasst_create();

    // !> Loop over levels and set some level specific parameters
    printf("do l = 1, pf%nlevels ...\n");
    cpf_user_obj_allocate();

    // !>  Set up some pfasst stuff
    printf("call pf_pfasst_setup(pf)");
    cpf_pfasst_setup();

    // !> add some hooks for output  (using a LibPFASST hook here)
    // call pf_add_hook(pf, -1, PF_POST_ITERATION, pf_echo_residual)

    // !>  Output run parameters to screen
    // call print_loc_options(pf,un_opt=6)
    
    // !>  Allocate initial consdition
    // call ndarray_build(y_0, [ 1 ])

    // !> Set the initial condition 
    // call y_0%setval(1.0_pfdp)

    // !> Do the PFASST time stepping
    // call pf_pfasst_run(pf, y_0, dt, 0.0_pfdp, nsteps)
    
    // !>  Wait for everyone to be done
    // call mpi_barrier(pf%comm%comm, ierror)

    // !>  Deallocate initial condition and final solution
    // call ndarray_destroy(y_0)
    
    // !>  Deallocate pfasst structure
    // call pf_pfasst_destroy(pf)
}
