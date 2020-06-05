module cpf_parameters
    use pfasst
    use cpf_utils
    use iso_c_binding

    ! Shadowed by cpf_parameter_t in cpf_parameter.h
    type, bind(C) :: cpf_parameter_t
        integer(c_int)  :: nlevels
        integer(c_int)  :: niters
        integer(c_int)  :: qtype
        logical(c_bool) :: use_proper_nodes
        logical(c_bool) :: use_composite_nodes
        logical(c_bool) :: use_no_left_q
        integer(c_int)  :: nsweeps(PF_MAXLEVS)
        integer(c_int)  :: nsweeps_pred(PF_MAXLEVS)
        integer(c_int)  :: nnodes(PF_MAXLEVS)
        real(c_double)  :: abs_res_tol
        real(c_double)  :: rel_res_tol
        logical(c_bool) :: PFASST_pred
        logical(c_bool) :: pipeline_pred
        integer(c_int)  :: nsweeps_burn
        integer(c_int)  :: q0_style
        logical(c_bool) :: Vcycle
        logical(c_bool) :: use_pysdc_V
        logical(c_bool) :: sweep_at_conv
        logical(c_bool) :: Finterp
        logical(c_bool) :: use_LUq
        logical(c_bool) :: use_Sform
        integer(c_int)  :: taui0
        logical(c_bool) :: use_sdc_sweeper
        logical(c_bool) :: use_rk_stepper
        integer(c_int)  :: nsteps_rk(PF_MAXLEVS)
        logical(c_bool) :: RK_pred
        logical(c_bool) :: debug
        logical(c_bool) :: save_residuals
        logical(c_bool) :: save_delta_q0
        logical(c_bool) :: save_errors
        logical(c_bool) :: save_json
        integer(c_int)  :: save_timings
        character(c_char) :: outdir(256)
    end type cpf_parameter_t

contains

    subroutine set_parameters(pf_prm, cpf_prm)
        type(pf_pfasst_t),     intent(inout)  :: pf_prm
        type(cpf_parameter_t), intent(in)   :: cpf_prm

        pf_prm%nlevels = cpf_prm%nlevels
        pf_prm%niters = cpf_prm%niters
        pf_prm%qtype = cpf_prm%qtype
        pf_prm%use_proper_nodes = cpf_prm%use_proper_nodes
        pf_prm%use_composite_nodes = cpf_prm%use_composite_nodes
        pf_prm%use_no_left_q = cpf_prm%use_no_left_q
        pf_prm%nsweeps = cpf_prm%nsweeps
        pf_prm%nsweeps_pred = cpf_prm%nsweeps_pred
        pf_prm%nnodes = cpf_prm%nnodes
        pf_prm%abs_res_tol = cpf_prm%abs_res_tol
        pf_prm%rel_res_tol = cpf_prm%rel_res_tol
        pf_prm%PFASST_pred = cpf_prm%PFASST_pred
        pf_prm%pipeline_pred = cpf_prm%pipeline_pred
        pf_prm%nsweeps_burn = cpf_prm%nsweeps_burn
        pf_prm%q0_style = cpf_prm%q0_style
        pf_prm%Vcycle = cpf_prm%Vcycle
        pf_prm%use_pysdc_V = cpf_prm%use_pysdc_V
        pf_prm%sweep_at_conv = cpf_prm%sweep_at_conv
        pf_prm%Finterp = cpf_prm%Finterp
        pf_prm%use_LUq = cpf_prm%use_LUq
        pf_prm%use_Sform = cpf_prm%use_Sform
        pf_prm%taui0 = cpf_prm%taui0
        pf_prm%use_sdc_sweeper = cpf_prm%use_sdc_sweeper
        pf_prm%use_rk_stepper = cpf_prm%use_rk_stepper
        pf_prm%nsteps_rk = cpf_prm%nsteps_rk
        pf_prm%RK_pred = cpf_prm%RK_pred
        pf_prm%debug = cpf_prm%debug
        pf_prm%save_residuals = cpf_prm%save_residuals
        pf_prm%save_delta_q0 = cpf_prm%save_delta_q0
        pf_prm%save_errors = cpf_prm%save_errors
        pf_prm%save_json = cpf_prm%save_json
        pf_prm%save_timings = cpf_prm%save_timings
        call c_f_string(cpf_prm%outdir, pf_prm%outdir)
    end subroutine set_parameters

    subroutine get_parameters(pf_prm, cpf_prm)
        type(pf_pfasst_t),     intent(in)   :: pf_prm
        type(cpf_parameter_t), intent(out)  :: cpf_prm

        cpf_prm%nlevels = pf_prm%nlevels
        cpf_prm%niters = pf_prm%niters
        cpf_prm%qtype = pf_prm%qtype
        cpf_prm%use_proper_nodes = pf_prm%use_proper_nodes
        cpf_prm%use_composite_nodes = pf_prm%use_composite_nodes
        cpf_prm%use_no_left_q = pf_prm%use_no_left_q
        cpf_prm%nsweeps = pf_prm%nsweeps
        cpf_prm%nsweeps_pred = pf_prm%nsweeps_pred
        cpf_prm%nnodes = pf_prm%nnodes
        cpf_prm%abs_res_tol = pf_prm%abs_res_tol
        cpf_prm%rel_res_tol = pf_prm%rel_res_tol
        cpf_prm%PFASST_pred = pf_prm%PFASST_pred
        cpf_prm%pipeline_pred = pf_prm%pipeline_pred
        cpf_prm%nsweeps_burn = pf_prm%nsweeps_burn
        cpf_prm%q0_style = pf_prm%q0_style
        cpf_prm%Vcycle = pf_prm%Vcycle
        cpf_prm%use_pysdc_V = pf_prm%use_pysdc_V
        cpf_prm%sweep_at_conv = pf_prm%sweep_at_conv
        cpf_prm%Finterp = pf_prm%Finterp
        cpf_prm%use_LUq = pf_prm%use_LUq
        cpf_prm%use_Sform = pf_prm%use_Sform
        cpf_prm%taui0 = pf_prm%taui0
        cpf_prm%use_sdc_sweeper = pf_prm%use_sdc_sweeper
        cpf_prm%use_rk_stepper = pf_prm%use_rk_stepper
        cpf_prm%nsteps_rk = pf_prm%nsteps_rk
        cpf_prm%RK_pred = pf_prm%RK_pred
        cpf_prm%debug = pf_prm%debug
        cpf_prm%save_residuals = pf_prm%save_residuals
        cpf_prm%save_delta_q0 = pf_prm%save_delta_q0
        cpf_prm%save_errors = pf_prm%save_errors
        cpf_prm%save_json = pf_prm%save_json
        cpf_prm%save_timings = pf_prm%save_timings
        call f_c_string(pf_prm%outdir, cpf_prm%outdir)
    end subroutine get_parameters

end module cpf_parameters

