module cpf_level
    use cpf_encap
    use cpf_imex_sweeper
    use iso_c_binding

    interface
        subroutine level_interpolate_cb(f_level_index, c_level_index, f_data, c_data, t, flags) bind(C)
            import :: c_double, c_int, c_ptr
            integer(c_int)  :: f_level_index, c_level_index
            type(c_ptr)     :: f_data, c_data
            real(c_double)  :: t
            integer(c_int)  :: flags
        end subroutine
        subroutine level_restrict_cb(f_level_index, c_level_index, f_data, c_data, t, flags) bind(C)
            import :: c_double, c_int, c_ptr
            integer(c_int)  :: f_level_index, c_level_index
            type(c_ptr)     :: f_data, c_data
            real(c_double)  :: t
            integer(c_int)  :: flags
        end subroutine
    end interface

    !>  extend the generic level type by defining transfer operators
    type, extends(pf_user_level_t) :: cpf_level_t
    contains
        procedure :: restrict
        procedure :: interpolate
    end type cpf_level_t

contains

    !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
    !>  These are the transfer functions that must be  provided for the level
    !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
    !>  Interpolate from coarse level to fine
    subroutine interpolate(this, f_lev, c_lev, f_vec, c_vec, t, flags)
        class(cpf_level_t),  intent(inout) :: this
        class(pf_level_t), intent(inout)      :: f_lev, c_lev  !  fine and coarse levels
        class(pf_encap_t),   intent(inout)    :: f_vec, c_vec  !  fine and coarse vectors
        real(pfdp),        intent(in   ) :: t                  !  Equation time
        integer, intent(in), optional :: flags                 !  Optional flags (not used here)

        class(cpf_encap_t), pointer :: y_f, y_c

        !>  Cast the abstract encap as my data type
        y_f => cast_as_cpf(f_vec)
        y_c => cast_as_cpf(c_vec)

        call level_interpolate_cb(f_lev%index, c_lev%index, y_f%data, y_c%data, t, flags)
    end subroutine interpolate

    !>  Restrict from fine level to coarse
    subroutine restrict(this, f_lev, c_lev, f_vec, c_vec, t, flags)
        class(cpf_level_t),  intent(inout) :: this
        class(pf_level_t), intent(inout)      :: f_lev, c_lev  !  fine and coarse levels
        class(pf_encap_t),   intent(inout)    :: f_vec, c_vec  !  fine and coarse vectors
        real(pfdp),        intent(in   ) :: t      !<  time of solution
        integer, intent(in), optional :: flags

        class(cpf_encap_t), pointer :: y_f, y_c

        !>  Cast the abstract encap as my data type
        y_f => cast_as_cpf(f_vec)
        y_c => cast_as_cpf(c_vec)

        call level_restrict_cb(f_lev%index, c_lev%index, y_f%data, y_c%data, t, flags)
    end subroutine restrict

end module cpf_level

