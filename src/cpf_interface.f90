! Interoperable routines to be called by user code
module cpfasst
    use cpf_main
    use cpf_parameters
    use cpf_utils
    use iso_c_binding
    implicit none

contains

    ! C interfaces for cpf_main subroutines

    subroutine cpf_initialize_from_nml(path) bind(C)
        character(c_char), intent(in) :: path(256)
        character(256) :: f_path

        call c_f_string(path, f_path)
        call initialize(path=f_path)
    end subroutine cpf_initialize_from_nml

    subroutine cpf_initialize_from_nlevels(nlevels) bind(C)
        integer(c_int), intent(in), value :: nlevels

        call initialize(nlevels=nlevels)
    end subroutine cpf_initialize_from_nlevels

    subroutine cpf_initialize_level(level_index, data_size) bind(C)
        integer(c_int), intent(in), value :: level_index
        integer(c_int), intent(in), value :: data_size
        call initialize_level(level_index, data_size)
    end subroutine cpf_initialize_level

    subroutine cpf_run(dt, nsteps) bind(C)
        real(c_double), intent(in), value :: dt
        integer(c_int), intent(in), value :: nsteps
        real(c_double) :: local_dt

        local_dt = dt
        call run(local_dt, nsteps)
    end subroutine cpf_run

    subroutine cpf_destroy() bind(C)
        call destroy()
    end subroutine cpf_destroy

    ! Getters/setters for cpf_run variables

    subroutine cpf_set_parameters(param) bind(C)
        type(c_ptr), intent(in), value :: param
        type(cpf_parameter_t), pointer :: param_fptr
        call c_f_pointer(param, param_fptr)
        call set_parameters(pf, param_fptr)
    end subroutine cpf_set_parameters

    subroutine cpf_get_parameters(param) bind(C)
        type(c_ptr), intent(in), value :: param
        type(cpf_parameter_t), pointer :: param_fptr
        call c_f_pointer(param, param_fptr)
        call get_parameters(pf, param_fptr)
    end subroutine cpf_get_parameters

    subroutine cpf_set_initial_condition(data) bind(C)
        type(c_ptr), intent(in), value :: data
        y_0%data = data
    end subroutine cpf_set_initial_condition

    subroutine cpf_set_solution_storage(data) bind(C)
        type(c_ptr), intent(in), value :: data
        y_end%data = data
    end subroutine cpf_set_solution_storage

    ! getters for run states

    function cpf_get_current_solution(level_index) result(data) bind(C)
        integer(c_int), intent(in), value :: level_index
        type(c_ptr)                       :: data
        type(cpf_encap_t), pointer :: cpf_qend
        cpf_qend => cast_to_cpf_encap(pf%levels(level_index)%qend)
        data = cpf_qend%data
    end function cpf_get_current_solution

    function cpf_get_endpoint_time() result(t) bind(C)
        real(c_double) :: t
        t = pf%state%t0 + pf%state%dt
    end function cpf_get_endpoint_time

    ! pf_add_hook interface
    subroutine cpf_add_custom_hook(level_index, hook, c_fun) bind(C)
        integer(c_int), intent(in), value :: level_index
        integer(c_int), intent(in), value :: hook
        type(c_funptr), intent(in), value :: c_fun
        procedure(pf_hook_p), pointer :: procptr

        call c_f_procpointer(c_fun, procptr)
        call pf_add_hook(pf, level_index, hook, procptr)
    end subroutine cpf_add_custom_hook

    ! pf_set_error interface
    subroutine cpf_set_error(level_index, error) bind(C)
        integer(c_int), intent(in), value :: level_index
        real(c_double), intent(in), value :: error

        call pf_set_error(pf, level_index, error)
    end subroutine cpf_set_error

end module cpfasst
