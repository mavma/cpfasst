module cpfasst
  use pfasst            !< This module has include statements for the main pfasst routines
  use pf_mod_mpi
  use cpf_level
  use cpf_encap
  use cpf_imex_sweeper
  use iso_c_binding

  interface
    subroutine setup_initial_condition_cb(data) bind(C)
      import :: c_ptr
      type(c_ptr),    intent(out) :: data
    end subroutine
    subroutine setup_final_condition_cb(data) bind(C)
      import :: c_ptr
      type(c_ptr),    intent(out) :: data
    end subroutine
  end interface

  type(pf_pfasst_t) :: pf  !<  the main pfasst structure
  type(pf_comm_t)   :: comm    !<  the communicator (here it is mpi)
  type(cpf_encap_t)   :: y_0      !<  the initial condition
  type(cpf_encap_t)   :: y_end      !<  the initial condition

contains

  subroutine cpf_mpi_create() bind(C)
    call pf_mpi_create(comm, MPI_COMM_WORLD)
  end subroutine cpf_mpi_create

  !> Create a PFASST object
  subroutine cpf_pfasst_create(fname) bind(C)
    character(c_char), intent(in) :: fname(256)
    character(256) :: pf_fname
    pf_fname = transfer(fname, pf_fname)
    call pf_pfasst_create(pf, comm, fname=pf_fname)
  end subroutine cpf_pfasst_create

  subroutine cpf_user_obj_allocate(data_size) bind(C)
    integer(c_int), intent(in) :: data_size
    integer :: l !!  Level loop index
    integer :: mpibuflen

    mpibuflen = data_size / sizeof(pfdp)
    if (mod(data_size, sizeof(pfdp)) /= 0) then
      mpibuflen = mpibuflen + 1 ! round up
    end if

    do l = 1, pf%nlevels
      !>  Allocate the user specific level object
      allocate(cpf_level_t::pf%levels(l)%ulevel)
      !>  Allocate the user specific data constructor
      allocate(cpf_factory::pf%levels(l)%ulevel%factory)
      !>  Add the sweeper to the level
      allocate(cpf_imex_sweeper_t::pf%levels(l)%ulevel%sweeper)
      !>  Set the size of the data and mpi buffer length on this level
      call pf_level_set_size(pf,l,[1],mpibuflen)
    end do
  end subroutine cpf_user_obj_allocate

  subroutine cpf_pfasst_setup() bind(C)
    call pf_pfasst_setup(pf)
  end subroutine cpf_pfasst_setup

  subroutine cpf_add_custom_hook(level_index, hook, c_fun) bind(C)
    integer(c_int),    intent(in)    :: level_index   !! which pfasst level to add hook
    integer(c_int),    intent(in)    :: hook          !! which hook to add
    type(c_funptr)                   :: c_fun         !! function pointer to c callback
    procedure(pf_hook_p), pointer :: procptr

    call c_f_procpointer(c_fun, procptr)
    call pf_add_hook(pf, level_index, hook, procptr)
  end subroutine cpf_add_custom_hook

  subroutine cpf_add_echo_residual_hook(level_index, hook) bind(C)
    integer(c_int),    intent(in)    :: level_index   !! which pfasst level to add hook
    integer(c_int),    intent(in)    :: hook          !! which hook to add
    call pf_add_hook(pf, level_index, hook, pf_echo_residual)
  end subroutine cpf_add_echo_residual_hook

  subroutine cpf_setup_ic() bind(C)
    call setup_initial_condition_cb(y_0%data)
    call setup_final_condition_cb(y_end%data)
  end subroutine cpf_setup_ic

  subroutine cpf_pfasst_run(dt, tend, nsteps) bind(C)
    real(c_double),    intent(inout)           :: dt   !!  The time step for each processor
    real(c_double),    intent(in   )           :: tend !!  The final time of run
    integer(c_int),    intent(in   ), optional :: nsteps  !!  The number of time steps
    call pf_pfasst_run(pf, y_0, dt, 0.0_pfdp, nsteps, y_end)
  end subroutine cpf_pfasst_run

  subroutine cpf_cleanup() bind(C)
    call cpf_encap_destroy(y_0)
    call cpf_encap_destroy(y_end)
    call pf_pfasst_destroy(pf)
  end subroutine cpf_cleanup

end module cpfasst
