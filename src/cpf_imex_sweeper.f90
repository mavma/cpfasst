module cpf_imex_sweeper
    use pf_mod_imex_sweeper
    use cpf_encap
    use iso_c_binding
    implicit none

    interface
        ! Interoperable interfaces to C callback functions that implement sweeper functionality
        ! Must match C declarations in header cpf_imex_sweeper.h

        subroutine cpf_imex_sweeper_initialize_cb(level_index, explicit, implicit) bind(C)
            import :: c_int, c_bool
            integer(c_int),  intent(in), value :: level_index
            logical(c_bool), intent(out)       :: explicit
            logical(c_bool), intent(out)       :: implicit
        end subroutine

        subroutine cpf_imex_sweeper_destroy_cb(level_index) bind(C)
            import :: c_int
            integer(c_int), intent(in), value :: level_index
        end subroutine

        subroutine cpf_imex_sweeper_f_eval_cb(y, t, level_index, f, piece) bind(C)
            import :: c_double, c_int, c_ptr
            type(c_ptr),    intent(in), value :: y
            real(c_double), intent(in), value :: t
            integer(c_int), intent(in), value :: level_index
            type(c_ptr),    intent(in), value :: f
            integer(c_int), intent(in), value :: piece
        end subroutine

        subroutine cpf_imex_sweeper_f_comp_cb(y, t, dtq, rhs, level_index, f) bind(C)
            import :: c_double, c_int, c_ptr
            type(c_ptr),    intent(in), value :: y
            real(c_double), intent(in), value :: t
            real(c_double), intent(in), value :: dtq
            type(c_ptr),    intent(in), value :: rhs
            integer(c_int), intent(in), value :: level_index
            type(c_ptr),    intent(in), value :: f
        end subroutine
    end interface

    type, extends(pf_imex_sweeper_t) :: cpf_imex_sweeper_t
    contains
        procedure :: f_eval     => cpf_imex_sweeper_f_eval
        procedure :: f_comp     => cpf_imex_sweeper_f_comp
        procedure :: initialize => cpf_imex_sweeper_initialize ! Overwrites imex sweeper initialize
        procedure :: destroy    => cpf_imex_sweeper_destroy    ! Overwrites imex sweeper destroy
    end type cpf_imex_sweeper_t

contains

    subroutine cpf_imex_sweeper_initialize(this, pf,level_index)
        class(cpf_imex_sweeper_t), intent(inout)         :: this
        type(pf_pfasst_t),         intent(inout), target :: pf
        integer,                   intent(in)            :: level_index
        logical(c_bool) :: cpf_exp, cpf_imp

        call this%imex_initialize(pf,level_index)
        call cpf_imex_sweeper_initialize_cb(level_index, cpf_exp, cpf_imp)
        this%explicit = cpf_exp
        this%implicit = cpf_imp
    end subroutine cpf_imex_sweeper_initialize

    subroutine cpf_imex_sweeper_destroy(this, pf, level_index)
        class(cpf_imex_sweeper_t), intent(inout)         :: this
        type(pf_pfasst_t),         intent(inout), target :: pf
        integer,                   intent(in)            :: level_index

        call cpf_imex_sweeper_destroy_cb(level_index)
        call this%imex_destroy(pf, level_index)
    end subroutine cpf_imex_sweeper_destroy

    subroutine cpf_imex_sweeper_f_eval(this, y, t, level_index, f, piece)
        class(cpf_imex_sweeper_t), intent(inout) :: this
        class(pf_encap_t),         intent(in)    :: y
        class(pf_encap_t),         intent(inout) :: f
        real(pfdp),                intent(in)    :: t
        integer,                   intent(in)    :: level_index
        integer,                   intent(in)    :: piece
        class(cpf_encap_t), pointer :: py, pf

        py => cast_to_cpf_encap(y)
        pf => cast_to_cpf_encap(f)
        call cpf_imex_sweeper_f_eval_cb(py%data, t, level_index, pf%data, piece)
    end subroutine cpf_imex_sweeper_f_eval

    subroutine cpf_imex_sweeper_f_comp(this, y, t, dtq, rhs, level_index, f,piece)
        class(cpf_imex_sweeper_t), intent(inout) :: this
        class(pf_encap_t), intent(inout) :: y
        real(pfdp),        intent(in)    :: t
        real(pfdp),        intent(in)    :: dtq
        class(pf_encap_t), intent(in)    :: rhs
        integer,           intent(in)    :: level_index
        class(pf_encap_t), intent(inout) :: f
        integer,           intent(in)    :: piece
        class(cpf_encap_t), pointer :: py, pf, prhs

        if(piece /= 2) call oops(__FILE__, __LINE__, 'Invalid value for piece in f_comp')
        py => cast_to_cpf_encap(y)
        pf => cast_to_cpf_encap(f)
        prhs => cast_to_cpf_encap(rhs)
        call cpf_imex_sweeper_f_comp_cb(py%data, t, dtq, prhs%data, level_index, pf%data)
    end subroutine cpf_imex_sweeper_f_comp

end module cpf_imex_sweeper

