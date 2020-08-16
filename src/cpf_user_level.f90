module cpf_user_level
    use cpf_encap
    use cpf_imex_sweeper
    use iso_c_binding

    interface
        ! Interoperable interfaces to C callback functions that implement level functionality
        ! Must match C declarations in header cpf_level.h

        subroutine cpf_user_level_interpolate_cb(f_level_index, c_level_index, f_data, c_data, t) bind(C)
            import :: c_double, c_int, c_ptr
            integer(c_int), intent(in), value :: f_level_index, c_level_index
            type(c_ptr),    intent(in), value :: f_data, c_data
            real(c_double), intent(in), value :: t
        end subroutine cpf_user_level_interpolate_cb

        subroutine cpf_user_level_restrict_cb(f_level_index, c_level_index, f_data, c_data, t) bind(C)
            import :: c_double, c_int, c_ptr
            integer(c_int), intent(in), value :: f_level_index, c_level_index
            type(c_ptr),    intent(in), value :: f_data, c_data
            real(c_double), intent(in), value :: t
        end subroutine cpf_user_level_restrict_cb
    end interface

    type, extends(pf_user_level_t) :: cpf_user_level_t
    contains
        procedure :: restrict    => cpf_user_level_restrict
        procedure :: interpolate => cpf_user_level_interpolate
    end type cpf_user_level_t

contains

    subroutine cpf_user_level_interpolate(this, f_lev, c_lev, f_vec, c_vec, t, flags)
        class(cpf_user_level_t), intent(inout)        :: this
        class(pf_level_t),       intent(inout)        :: f_lev, c_lev
        class(pf_encap_t),       intent(inout)        :: f_vec, c_vec
        real(pfdp),              intent(in)           :: t
        integer,                 intent(in), optional :: flags
        type(cpf_encap_t), pointer :: y_f, y_c

        y_f => cast_to_cpf_encap(f_vec)
        y_c => cast_to_cpf_encap(c_vec)
        call cpf_user_level_interpolate_cb(f_lev%index, c_lev%index, y_f%data, y_c%data, t)
    end subroutine cpf_user_level_interpolate

    subroutine cpf_user_level_restrict(this, f_lev, c_lev, f_vec, c_vec, t, flags)
        class(cpf_user_level_t), intent(inout)        :: this
        class(pf_level_t),       intent(inout)        :: f_lev, c_lev
        class(pf_encap_t),       intent(inout)        :: f_vec, c_vec
        real(pfdp),              intent(in)           :: t
        integer,                 intent(in), optional :: flags
        type(cpf_encap_t), pointer :: y_f, y_c

        y_f => cast_to_cpf_encap(f_vec)
        y_c => cast_to_cpf_encap(c_vec)
        call cpf_user_level_restrict_cb(f_lev%index, c_lev%index, y_f%data, y_c%data, t)
    end subroutine cpf_user_level_restrict

end module cpf_user_level

