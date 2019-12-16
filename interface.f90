!>  C adapter for LibPFASST/Tutorials/EX1_Dahlquist
module cpfasst
  use pfasst
  use pf_mod_mpi
  use pf_mod_ndarray
  use iso_c_binding

  type(pf_pfasst_t) :: pf_pfasst  !<  the main pfasst structure
  type(pf_comm_t)   :: pf_comm    !<  the communicator (here it is mpi)
  type(pf_ndarray_t):: y_0      !<  the initial condition
  character(256)    :: pf_fname   !<  file name for input of PFASST parameters

contains

  subroutine cpf_probin_init() bind(C)
    use probin
    call probin_init(pf_fname)
  end subroutine cpf_probin_init

  !> Subroutine to create an MPI based PFASST communicator using the MPI communicator *mpi_comm*
  subroutine cpf_mpi_create() bind(C)
    ! integer(c_int), intent(in) :: mpi_comm

    call pf_mpi_create(pf_comm, MPI_COMM_WORLD)

  end subroutine cpf_mpi_create

  !> Create a PFASST object
  subroutine cpf_pfasst_create() bind(C)
    ! TODO: check interesting values for Fortran true/false
    ! TODO: figure out interop handling for the arguments
    !integer(c_int), intent(in), optional :: nlevels   !! number of pfasst levels
    !logical(c_bool), intent(in), optional :: nocmd     !! Determines if command line variables are to be read
    
    call pf_pfasst_create(pf_pfasst, pf_comm, fname=pf_fname)
  end subroutine cpf_pfasst_create

  subroutine cpf_user_obj_allocate() bind(C) !TODO: define user objects in target language? How??
    use pf_my_level
    use pf_my_sweeper
    
    integer :: l !!  Level loop index

    do l = 1, pf_pfasst%nlevels
      !>  Allocate the user specific level object
      allocate(my_level_t::pf_pfasst%levels(l)%ulevel)
      !>  Allocate the user specific data constructor
      allocate(pf_ndarray_factory_t::pf_pfasst%levels(l)%ulevel%factory)
      !>  Allocate the sweeper at this level
      allocate(my_sweeper_t::pf_pfasst%levels(l)%ulevel%sweeper)
      !>  Set the size of the data on this level (here just one) // TODO: take as user input
      call pf_level_set_size(pf_pfasst,l,[1])
    end do
  end subroutine cpf_user_obj_allocate

  subroutine cpf_pfasst_setup() bind(C)
    call pf_pfasst_setup(pf_pfasst)
  end subroutine cpf_pfasst_setup

  subroutine cpf_add_hook() bind(C)
    call pf_add_hook(pf_pfasst, -1, PF_POST_ITERATION, pf_echo_residual)
  end subroutine cpf_add_hook

  subroutine cpf_print_loc_options() bind(C)
    use probin
    call print_loc_options(pf_pfasst,un_opt=6)
  end subroutine cpf_print_loc_options

  subroutine cpf_setup_ic() bind(C)
    call ndarray_build(y_0, [ 1 ])
    call y_0%setval(1.0_pfdp)
  end subroutine cpf_setup_ic 

  subroutine cpf_pfasst_run() bind(C)
    use probin
    call pf_pfasst_run(pf_pfasst, y_0, dt, 0.0_pfdp, nsteps)
  end subroutine cpf_pfasst_run 

  subroutine cpf_cleanup() bind(C)
    call ndarray_destroy(y_0)
    call pf_pfasst_destroy(pf_pfasst)
  end subroutine cpf_cleanup 

  

end module cpfasst
