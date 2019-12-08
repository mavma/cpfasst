program main
  use pf_mod_mpi

  integer ::  ierror

  !> Initialize MPI
  call mpi_init(ierror)
  if (ierror /= 0) &
       stop "ERROR: Can't initialize MPI."

  !> Call the  solver 
  call run_pfasst()

  !> Close mpi
  call mpi_finalize(ierror)

contains
  !>  This subroutine setups and calls libpfasst 
  subroutine run_pfasst()  
    use cpfasst       !<  This module has include statements for the main pfasst routines
    use probin        !<  Local module reading/parsing problem parameters

    implicit none

    !>  Local variables
    !type(pf_ndarray_t):: y_0      !<  the initial condition

    !> Read problem parameters
    call cpf_probin_init()

    !>  Set up communicator
    call cpf_mpi_create(MPI_COMM_WORLD)

    !>  Create the pfasst structure
    call cpf_pfasst_create()

    !> Loop over levels and set some level specific parameters
    call cpf_user_obj_allocate()

    !>  Set up some pfasst stuff
    call cpf_pfasst_setup()

    ! !> add some hooks for output  (using a LibPFASST hook here)
    ! call pf_add_hook(pf, -1, PF_POST_ITERATION, pf_echo_residual)

    ! !>  Output run parameters to screen
    ! call print_loc_options(pf,un_opt=6)
    
    ! !>  Allocate initial consdition
    ! call ndarray_build(y_0, [ 1 ])

    ! !> Set the initial condition 
    ! call y_0%setval(1.0_pfdp)

    ! !> Do the PFASST time stepping
    ! call pf_pfasst_run(pf, y_0, dt, 0.0_pfdp, nsteps)
    
    ! !>  Wait for everyone to be done
    ! call mpi_barrier(pf%comm%comm, ierror)

    ! !>  Deallocate initial condition and final solution
    ! call ndarray_destroy(y_0)
    
    ! !>  Deallocate pfasst structure
    ! call pf_pfasst_destroy(pf)

  end subroutine run_pfasst

end program
