! Interoperable routines to be called by user code
module cpfasst
    use cpf_main
    use cpf_parameters
    use cpf_utils
    use iso_c_binding
    implicit none

contains

    ! C interfaces for cpf_main subroutines

    subroutine cpf_initialize_pfasst(path, nlevels) bind(C)
        character(c_char), intent(in), optional :: path(256)
        integer(c_int),    intent(in), optional :: nlevels
        character(256) :: f_path

        if(present(path) .eqv. present(nlevels)) then
            call oops(__FILE__, __LINE__, 'cpf_initialize must be called with either "path" or "nlevels" argument')
        end if
        call c_f_string(path, f_path)
        call initialize(path=f_path)
    end subroutine cpf_initialize_pfasst

    subroutine cpf_initialize_level(level_index, data_size) bind(C)
        integer(c_int), intent(in) :: level_index
        integer(c_int), intent(in) :: data_size
        call initialize_level(level_index, data_size)
    end subroutine cpf_initialize_level

    subroutine cpf_run(dt, tend, nsteps) bind(C)
        real(c_double), intent(inout)           :: dt
        real(c_double), intent(in),    optional :: tend
        integer(c_int), intent(in),    optional :: nsteps

        if(present(tend) .eqv. present(nsteps)) then
            call oops(__FILE__, __LINE__, 'cpf_run must be called with either "tend" or "nsteps" argument')
        end if
        call run(dt, tend=tend, nsteps=nsteps)
    end subroutine cpf_run

    subroutine cpf_destroy() bind(C)
        call destroy()
    end subroutine cpf_destroy

    ! Getters/setters for cpf_run variables

    subroutine cpf_set_parameters(param) bind(C)
        type(c_ptr), intent(inout) :: param
        type(cpf_parameter_t), pointer :: param_fptr
        call c_f_pointer(param, param_fptr)
        call set_parameters(pf, param_fptr)
    end subroutine cpf_set_parameters

    subroutine cpf_get_parameters(param) bind(C)
        type(c_ptr) :: param
        type(cpf_parameter_t), pointer :: param_fptr
        call c_f_pointer(param, param_fptr)
        call get_parameters(pf, param_fptr)
    end subroutine cpf_get_parameters

    subroutine cpf_set_initial_condition(data) bind(C)
        type(c_ptr) :: data
        y_0%data = data
    end subroutine cpf_set_initial_condition

    subroutine cpf_set_final_condition(data) bind(C)
        type(c_ptr) :: data
        y_end%data = data
    end subroutine cpf_set_final_condition

    ! Custom hook interface

    subroutine cpf_add_custom_hook(level_index, hook, c_fun) bind(C)
        integer(c_int),    intent(in)    :: level_index   !! which pfasst level to add hook
        integer(c_int),    intent(in)    :: hook          !! which hook to add
        type(c_funptr)                   :: c_fun         !! function pointer to c callback
        procedure(pf_hook_p), pointer :: procptr

        call c_f_procpointer(c_fun, procptr)
        call pf_add_hook(pf, level_index, hook, procptr)
    end subroutine cpf_add_custom_hook

end module cpfasst
