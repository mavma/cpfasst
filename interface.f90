!>  C adapter for LibPFASST/Tutorials/EX1_Dahlquist
module cadapt
  use pfasst

  type(pf_pfasst_t) :: pf_pfasst  !<  the main pfasst structure
  type(pf_comm_t)   :: pf_comm    !<  the communicator (here it is mpi)
  !type(pf_ndarray_t):: y_0      !<  the initial condition
  character(256)    :: pf_fname   !<  file name for input of PFASST parameters

contains
  !> Subroutine to create an MPI based PFASST communicator using the MPI communicator *mpi_comm*
  subroutine c_pf_mpi_create(mpi_comm)
    integer,         intent(in)  :: mpi_comm

    call pf_mpi_create(pf_comm, mpi_comm)

  end subroutine c_pf_mpi_create

  !> Create a PFASST object
  subroutine c_pf_pfasst_create(nlevels, fname, nocmd) !TODO: add proper C bindings to these functions
    integer,           intent(in   ), optional :: nlevels   !! number of pfasst levels
    character(len=*),  intent(in   ), optional :: fname     !! Input file for pfasst parameters
    logical,           intent(in   ), optional :: nocmd     !! Determines if command line variables are to be read

    call pf_pfasst_create(pf_pfasst, pf_comm, nlevels, fname, nocmd)
  end subroutine c_pf_pfasst_create

  subroutine c_user_obj_allocate() !TODO: define user objects in target language? How??
    use pf_my_level
    use pf_my_sweeper

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
  end subroutine c_user_obj_allocate

  subroutine c_pf_pfasst_setup()
    call pf_pfasst_setup(pf_pfasst)
  end subroutine c_pf_pfasst_setup

end module cadapt
