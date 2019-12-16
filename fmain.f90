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
    call cpf_add_hook()

    ! !>  Output run parameters to screen
    call cpf_print_loc_options()
    
    ! !>  Allocate initial consdition
    ! !> Set the initial condition
    call cpf_setup_ic() 
    
    ! !> Do the PFASST time stepping
    call cpf_pfasst_run()
    
    ! !>  Wait for everyone to be done
    ! call mpi_barrier(pf%comm%comm, ierror) FIXME :(

    ! !>  Deallocate initial condition and final solution
    ! !>  Deallocate pfasst structure
    call cpf_cleanup()

  end subroutine run_pfasst

end program
