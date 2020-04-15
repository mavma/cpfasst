module cpf_imex_sweeper
  use pf_mod_ndarray
  use pf_mod_imex_sweeper
  use cpf_encap
  use iso_c_binding

  interface
    subroutine sweeper_f_eval_cb(y, t, level_index, f, piece) bind(C)
      import :: c_double, c_int, c_ptr
      type(c_ptr)     :: y
      real(c_double)  :: t
      integer(c_int)  :: level_index
      type(c_ptr)     :: f
      integer(c_int)  :: piece
    end subroutine
    subroutine sweeper_f_comp_cb(y, t, dtq, rhs, level_index, f, piece) bind(C)
      import :: c_double, c_int, c_ptr
      type(c_ptr)     :: y
      real(c_double)  :: t
      real(c_double)  :: dtq
      type(c_ptr)     :: rhs
      integer(c_int)  :: level_index
      type(c_ptr)     :: f
      integer(c_int)  :: piece
    end subroutine
  end interface

  !>  extend the imex sweeper type with stuff we need to compute rhs
  type, extends(pf_imex_sweeper_t) :: cpf_imex_sweeper_t
   contains
     procedure :: f_eval    !  Computes the advection and diffusion terms
     procedure :: f_comp    !  Does implicit solve
     ! TODO required?
     procedure :: initialize !  Overwrites imex sweeper initialize
     procedure :: destroy    !  Overwrites imex sweeper destroy
  end type cpf_imex_sweeper_t

contains

  ! TODO required?
  !>  Routine to set up sweeper variables and operators
  subroutine initialize(this, pf,level_index)
    class(cpf_imex_sweeper_t), intent(inout) :: this
    type(pf_pfasst_t), intent(inout),target :: pf
    integer, intent(in) :: level_index

    !>  Call the imex sweeper initialization
    call this%imex_initialize(pf,level_index)

    !>  Set variables for explicit and implicit parts (just to show you can)
    this%implicit=.TRUE.
    this%explicit=.TRUE.

  end subroutine initialize

  ! TODO required?
  !>  destroy the sweeper type
  subroutine destroy(this, pf,level_index)
    class(cpf_imex_sweeper_t), intent(inout) :: this
    type(pf_pfasst_t), intent(inout), target :: pf
    integer, intent(in) :: level_index

    !>  Call the imex sweeper destroy
    call this%imex_destroy(pf,level_index)

    !  Nothing to do

  end subroutine destroy

  !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
  ! These routines must be provided for the sweeper
  !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
  ! Evaluate the explicit function at y, t.
  subroutine f_eval(this, y, t, level_index, f, piece)
    use probin, only:  lam1, lam2
    use iso_c_binding, only: c_ptr
    class(cpf_imex_sweeper_t), intent(inout) :: this
    class(pf_encap_t),   intent(in   ) :: y
    class(pf_encap_t),   intent(inout) :: f
    real(pfdp),          intent(in   ) :: t
    integer,             intent(in   ) :: level_index
    integer,             intent(in   ) :: piece

    class(cpf_encap_t), pointer :: py, pf

    !> Cast to cpf_encap_t
    py => cast_as_cpf(y)
    pf => cast_as_cpf(f)

    ! Compute the function values
    call sweeper_f_eval_cb(py%data, t, level_index, pf%data, piece)

    ! Compute the function values FIXME remove
    select case (piece)
    case (1)  ! Explicit piece
      pf%y = lam1*py%y
    case (2)  ! Implicit piece
      pf%y = lam2*py%y
    case DEFAULT
      print *,'Bad case for piece in f_eval ', piece
      call exit(0)
    end select

  end subroutine f_eval

  !> Solve for y and return f2 also.
  subroutine f_comp(this, y, t, dtq, rhs, level_index, f,piece)
    use probin, only:  lam1, lam2
    use iso_c_binding, only: c_ptr
    class(cpf_imex_sweeper_t), intent(inout) :: this
    class(pf_encap_t),   intent(inout) :: y
    real(pfdp),          intent(in   ) :: t
    real(pfdp),          intent(in   ) :: dtq
    class(pf_encap_t),   intent(in   ) :: rhs
    integer,             intent(in   ) :: level_index
    class(pf_encap_t),   intent(inout) :: f
    integer,             intent(in   ) :: piece

    class(cpf_encap_t), pointer :: py, pf, prhs

    !> Cast to cpf_encap_t
    py => cast_as_cpf(y)
    pf => cast_as_cpf(f)
    prhs => cast_as_cpf(rhs)

    call sweeper_f_comp_cb(py%data, t, dtq, prhs%data, level_index, pf%data, piece)


    ! FIXME remove
    if (piece == 2) then

      !  Do the solve
      py%y =  prhs%y/(1.0_pfdp - dtq*lam2)

      !  The function is easy to derive  (equivalent to lam2*y)
      pf%y = (py%y - prhs%y) / dtq
    else
      print *,'Bad piece in f_comp ',piece
      call exit(0)
    end if

  end subroutine f_comp

  ! FIXME: remove
  !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
  !>  Here are some extra routines to help out
  !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
  !> Routine to set initial condition.
  !subroutine initial(y_0)
  !  type(cpf_encap_t), intent(inout) :: y_0
  !  call exact(0.0_pfdp, y_0%y)
  !end subroutine initial

  !> Routine to return the exact solution
  subroutine exact(t, yex)
    use probin, only: lam1,lam2
    real(pfdp), intent(in)  :: t
    real(pfdp), intent(out) :: yex

    yex=exp((lam1+lam2)*t)

  end subroutine exact


end module cpf_imex_sweeper

