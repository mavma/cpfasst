module cpf_imex_sweeper
    use pf_mod_imex_sweeper
    use cpf_encap
    use iso_c_binding
    implicit none

    interface
        ! Interfaces to C callbacks that must be defined by the user

        subroutine imex_sweeper_initialize_cb(level_index, explicit, implicit) bind(C)
            import :: c_int, c_bool
            integer(c_int)  :: level_index
            logical(c_bool) :: explicit
            logical(c_bool) :: implicit
        end subroutine

        subroutine imex_sweeper_destroy_cb(level_index) bind(C)
            import :: c_int, c_bool
            integer(c_int)  :: level_index
        end subroutine

        subroutine imex_sweeper_f_eval_cb(y, t, level_index, f, piece) bind(C)
            import :: c_double, c_int, c_ptr
            type(c_ptr)     :: y
            real(c_double)  :: t
            integer(c_int)  :: level_index
            type(c_ptr)     :: f
            integer(c_int)  :: piece
        end subroutine

        subroutine imex_sweeper_f_comp_cb(y, t, dtq, rhs, level_index, f, piece) bind(C)
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

    type, extends(pf_imex_sweeper_t) :: cpf_imex_sweeper_t
    contains
        procedure :: f_eval
        procedure :: f_comp
        procedure :: initialize => sweeper_initialize ! Overwrites imex sweeper initialize
        procedure :: destroy => sweeper_destroy       ! Overwrites imex sweeper destroy
    end type cpf_imex_sweeper_t

contains

    ! Set up sweeper variables and operators
    subroutine sweeper_initialize(this, pf,level_index)
        class(cpf_imex_sweeper_t), intent(inout) :: this
        type(pf_pfasst_t), intent(inout),target :: pf
        integer, intent(in) :: level_index
        logical(c_bool) :: cpf_exp, cpf_imp

        call this%imex_initialize(pf,level_index)
        cpf_exp = this%explicit
        cpf_imp = this%implicit
        call imex_sweeper_initialize_cb(level_index, cpf_exp, cpf_imp)
        this%explicit = cpf_exp
        this%implicit = cpf_imp
    end subroutine sweeper_initialize

    ! Destroy the sweeper
    subroutine sweeper_destroy(this, pf,level_index)
        class(cpf_imex_sweeper_t), intent(inout) :: this
        type(pf_pfasst_t), intent(inout), target :: pf
        integer, intent(in) :: level_index

        call this%imex_destroy(pf,level_index)
        call imex_sweeper_destroy_cb(level_index)
    end subroutine sweeper_destroy

    ! Evaluate the explicit function at y, t.
    subroutine f_eval(this, y, t, level_index, f, piece)
        use iso_c_binding, only: c_ptr
        class(cpf_imex_sweeper_t), intent(inout) :: this
        class(pf_encap_t),   intent(in   ) :: y
        class(pf_encap_t),   intent(inout) :: f
        real(pfdp),          intent(in   ) :: t
        integer,             intent(in   ) :: level_index
        integer,             intent(in   ) :: piece
        class(cpf_encap_t), pointer :: py, pf

        py => cast_to_cpf_encap(y)
        pf => cast_to_cpf_encap(f)
        call imex_sweeper_f_eval_cb(py%data, t, level_index, pf%data, piece)
    end subroutine f_eval

    ! Solve for y and return f2 also.
    subroutine f_comp(this, y, t, dtq, rhs, level_index, f,piece)
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

        py => cast_to_cpf_encap(y)
        pf => cast_to_cpf_encap(f)
        prhs => cast_to_cpf_encap(rhs)
        call imex_sweeper_f_comp_cb(py%data, t, dtq, prhs%data, level_index, pf%data, piece)
    end subroutine f_comp

end module cpf_imex_sweeper

