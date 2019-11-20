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
  subroutine c_pf_pfasst_create(nlevels, fname, nocmd)
    integer,           intent(in   ), optional :: nlevels   !! number of pfasst levels
    character(len=*),  intent(in   ), optional :: fname     !! Input file for pfasst parameters
    logical,           intent(in   ), optional :: nocmd     !! Determines if command line variables are to be read

    call pf_pfasst_create(pf_pfasst, pf_comm, nlevels, fname, nocmd)
  end subroutine c_pf_pfasst_create

end module cadapt
