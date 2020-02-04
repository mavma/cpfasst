!>  C adapter for LibPFASST/Tutorials/EX1_Dahlquist
module cpfasst
  use pfasst            !< This module has include statements for the main pfasst routines
  use pf_my_level       !< Local module for level
  use hooks             !< Local module for diagnostics and i/o
  use probin            !< Local module reading/parsing problem parameters
  use cpf_encap
  use cpf_imex_sweeper
  use pf_mod_mpi

  type(pf_pfasst_t) :: pf  !<  the main pfasst structure
  type(pf_comm_t)   :: comm    !<  the communicator (here it is mpi)
  type(cpf_encap_t)   :: y_0      !<  the initial condition
  type(cpf_encap_t)   :: y_end      !<  the initial condition
  character(256)    :: pf_fname   !<  file name for input of PFASST parameters

contains

  subroutine set_fname(fname) bind(C)
    use iso_c_binding, only: c_char, c_int
    character(c_char) :: fname(256)
    pf_fname = transfer(fname, pf_fname)
  end subroutine set_fname

  subroutine cpf_probin_init() bind(C)
    use probin
    call probin_init(pf_fname)
  end subroutine cpf_probin_init

  subroutine cpf_mpi_create() bind(C)
    call pf_mpi_create(comm, MPI_COMM_WORLD)
  end subroutine cpf_mpi_create

  !> Create a PFASST object
  subroutine cpf_pfasst_create() bind(C)
    call pf_pfasst_create(pf, comm, fname=pf_fname)
  end subroutine cpf_pfasst_create

  subroutine cpf_user_obj_allocate() bind(C)
    integer :: l !!  Level loop index

    do l = 1, pf%nlevels
      !>  Allocate the user specific level object
      allocate(my_level_t::pf%levels(l)%ulevel)
      !>  Allocate the user specific data constructor
      allocate(cpf_factory::pf%levels(l)%ulevel%factory)
      !>  Add the sweeper to the level
      allocate(cpf_imex_sweeper_t::pf%levels(l)%ulevel%sweeper)
      !>  Set the size of the data on this level (here just one)
      call pf_level_set_size(pf,l,[1])
    end do
  end subroutine cpf_user_obj_allocate

  subroutine cpf_pfasst_setup() bind(C)
    call pf_pfasst_setup(pf)
  end subroutine cpf_pfasst_setup

  subroutine cpf_add_hook() bind(C)
    call pf_add_hook(pf, -1, PF_POST_ITERATION, pf_echo_residual)
    ! call pf_add_hook(pf, -1, PF_POST_ITERATION, echo_error)
  end subroutine cpf_add_hook

  subroutine cpf_print_loc_options() bind(C)
    call print_loc_options(pf,un_opt=6)
  end subroutine cpf_print_loc_options

  subroutine cpf_setup_ic() bind(C)
    call cpf_encap_build(y_0, 0, [ 0 ]) !FIXME: what to pass for extra args here?
    call cpf_encap_build(y_end, 0, [ 0 ]) !FIXME: what to pass for extra args here?
    call y_0%setval(1.0_pfdp)
  end subroutine cpf_setup_ic

  subroutine cpf_pfasst_run() bind(C)
    call pf_pfasst_run(pf, y_0, dt, 0.0_pfdp, nsteps,y_end)
  end subroutine cpf_pfasst_run 

  subroutine cpf_cleanup() bind(C)
    call cpf_encap_destroy(y_0)
    call cpf_encap_destroy(y_end)
    call pf_pfasst_destroy(pf)
  end subroutine cpf_cleanup

end module cpfasst
