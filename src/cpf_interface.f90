! Interoperable routines to be called by user code
module cpfasst
    use cpf_run
    use cpf_parameters
    use cpf_utils
    use iso_c_binding
    implicit none

contains

    ! C interfaces for cpf_run subroutines

    subroutine cpf_initialize_from_nml(path) bind(C)
        character(c_char), intent(in) :: path(256)
        character(256) :: f_path
        call c_f_string(path, f_path)
        call initialize(path=f_path)
    end subroutine cpf_initialize_from_nml

    subroutine cpf_initialize_default(nlevels) bind(C)
        integer(c_int), intent(in) :: nlevels
        call initialize(nlevels=nlevels)
    end subroutine cpf_initialize_default

    subroutine cpf_allocate_level(level_index, data_size) bind(C)
        integer(c_int), intent(in) :: level_index
        integer(c_int), intent(in) :: data_size
        call allocate_level(level_index, data_size)
    end subroutine cpf_allocate_level

    subroutine cpf_run_tend(dt, tend) bind(C)
        real(c_double), intent(inout) :: dt
        real(c_double), intent(in) :: tend
        call run(dt, tend=tend)
    end subroutine cpf_run_tend

    subroutine cpf_run_nsteps(dt, nsteps) bind(C)
        real(c_double), intent(inout) :: dt
        integer(c_int), intent(in) :: nsteps
        call run(dt, nsteps=nsteps)
    end subroutine cpf_run_nsteps

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

    subroutine cpf_set_ic(data) bind(C)
        type(c_ptr) :: data
        y_0%data = data
    end subroutine cpf_set_ic

    ! Optional interfaces

    subroutine cpf_add_custom_hook(level_index, hook, c_fun) bind(C)
        integer(c_int),    intent(in)    :: level_index   !! which pfasst level to add hook
        integer(c_int),    intent(in)    :: hook          !! which hook to add
        type(c_funptr)                   :: c_fun         !! function pointer to c callback
        procedure(pf_hook_p), pointer :: procptr

        call c_f_procpointer(c_fun, procptr)
        call pf_add_hook(pf, level_index, hook, procptr)
    end subroutine cpf_add_custom_hook

    subroutine cpf_add_echo_residual_hook(level_index, hook) bind(C)
        integer(c_int),    intent(in)    :: level_index   !! which pfasst level to add hook
        integer(c_int),    intent(in)    :: hook          !! which hook to add
        call pf_add_hook(pf, level_index, hook, pf_echo_residual)
    end subroutine cpf_add_echo_residual_hook

end module cpfasst
