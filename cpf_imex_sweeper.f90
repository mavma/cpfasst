!
! This file is part of LIBPFASST.
!
!
!> Sweeper and RHS specification for Dahlquist example.
!>     u_t = lam1*u + lam2*u
module cpf_imex_sweeper
  use pf_mod_ndarray
  use pf_mod_imex_sweeper
  use iso_c_binding

  interface
    subroutine c_f_eval_interface(y, ydim, t, level_index, f, fdim, piece)
      import :: c_double, c_int, c_ptr
      type(c_ptr), value    :: y
      integer(c_int), value :: ydim
      real(c_double), value :: t
      integer(c_int), value :: level_index
      type(c_ptr), value    :: f
      integer(c_int), value :: fdim
      integer(c_int), value :: piece
    end subroutine
  end interface

  procedure(c_f_eval_interface), pointer :: c_f_eval
  procedure(c_f_eval_interface), pointer :: c_f_comp !FIXME

  !>  extend the imex sweeper type with stuff we need to compute rhs
  type, extends(pf_imex_sweeper_t) :: cpf_imex_sweeper_t
   contains
     procedure :: f_eval    !  Computes the advection and diffusion terms
     procedure :: f_comp    !  Does implicit solves
  end type cpf_imex_sweeper_t

contains

  subroutine set_f_eval(f) bind(c, name="cpf_imex_sweeper_set_feval")
    use iso_c_binding
    type(c_funptr), value :: f

    call c_f_procpointer(f, c_f_eval)

  end subroutine

  subroutine set_f_comp(f) bind(c, name="cpf_imex_sweeper_set_fcomp")
    use iso_c_binding
    type(c_funptr), value :: f

    call c_f_procpointer(f, c_f_comp)

  end subroutine

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
    
    real(pfdp),      pointer :: yvec(:), fvec(:)
    type(c_ptr) :: fptr, yptr

    !> Grab the arrays from the encapsulation
    yvec => get_array1d(y)
    fvec => get_array1d(f)

    fptr = c_loc(fvec)
    yptr = c_loc(yvec)

    ! without an assignment to f here, changes on C side don't "take", but WHY
    fvec = yvec

    ! Compute the function values
    call c_f_eval(yptr, size(yvec), t, level_index, fptr, size(fvec), piece)

  end subroutine f_eval

  !> Solve for y and return f2 also.
  subroutine f_comp(this, y, t, dtq, rhs, level_index, f,piece)
    use probin, only:  lam1, lam2
    class(cpf_imex_sweeper_t), intent(inout) :: this
    class(pf_encap_t),   intent(inout) :: y
    real(pfdp),          intent(in   ) :: t
    real(pfdp),          intent(in   ) :: dtq
    class(pf_encap_t),   intent(in   ) :: rhs
    integer,             intent(in   ) :: level_index
    class(pf_encap_t),   intent(inout) :: f
    integer,             intent(in   ) :: piece

    real(pfdp),      pointer :: yvec(:), rhsvec(:), fvec(:)
    
    if (piece == 2) then
       !> Grab the arrays from the encapsulation       
       yvec  => get_array1d(y)
       rhsvec => get_array1d(rhs)
       fvec => get_array1d(f)

       !  Do the solve
       yvec =  rhsvec/(1.0_pfdp - dtq*lam2)

       !  The function is easy to derive  (equivalent to lam2*yvec)
       fvec = (yvec - rhsvec) / dtq
    else
       print *,'Bad piece in f_comp ',piece
       call exit(0)
    end if
  end subroutine f_comp

end module cpf_imex_sweeper

