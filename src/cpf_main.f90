! High level convenience functions for running cpfasst
module cpf_main
    use pfasst
    use pf_mod_mpi
    use cpf_level
    use cpf_encap
    use cpf_imex_sweeper
    use cpf_utils
    implicit none

    type(pf_pfasst_t) :: pf     !<  the main pfasst structure
    type(pf_comm_t)   :: comm   !<  the communicator (here it is mpi)
    type(cpf_encap_t) :: y_0    !<  the initial condition
    type(cpf_encap_t) :: y_end  !<  the final condition

contains

    subroutine initialize(path, nlevels)
        character(len=*), intent(in), optional :: path
        integer,          intent(in), optional :: nlevels
        call pf_mpi_create(comm, MPI_COMM_WORLD)
        call pf_pfasst_create(pf, comm, fname=path, nlevels=nlevels, nocmd=.true.)
    end subroutine initialize

    subroutine initialize_level(l, data_size)
        integer, intent(in) :: l            ! level index
        integer, intent(in) :: data_size    ! size in bytes of user data for this level

        ! allocate level object
        allocate(cpf_level_t::pf%levels(l)%ulevel)
        ! allocate data constructor
        allocate(cpf_factory::pf%levels(l)%ulevel%factory)
        ! allocate sweeper
        allocate(cpf_imex_sweeper_t::pf%levels(l)%ulevel%sweeper)
        ! check that data_size is a multiple of pfdp
        if(modulo(data_size, pfdp) /= 0) call oops(__FILE__, __LINE__, 'Data size must be a multiple of sizeof(double)')
        ! level size here is always 1, the actual size is handled by user code in C
        call pf_level_set_size(pf, l, [1], data_size)
    end subroutine initialize_level

    subroutine run(dt, nsteps, tend)
        real(pfdp), intent(inout)        :: dt        !!  Time step for each processor
        integer,    intent(in), optional :: nsteps    !!  Number of time steps
        real(pfdp), intent(in), optional :: tend      !!  Final time of run
        real(pfdp) :: tend_local

        ! check that initial condition was set
        if(c_associated(y_0%data, C_NULL_PTR) .or. c_associated(y_end%data, C_NULL_PTR)) then
            call oops(__FILE__, __LINE__, 'Initial condition and final solution must be set before running')
        end if
        ! further setup of pfasst data
        call pf_pfasst_setup(pf)
        ! start pfasst run
        if(.not. present(tend)) tend_local = 0.0_pfdp
        call pf_pfasst_run(pf, y_0, dt, tend_local, nsteps, y_end)
    end subroutine run

    subroutine destroy()
        call pf_pfasst_destroy(pf)
    end subroutine destroy

end module cpf_main
