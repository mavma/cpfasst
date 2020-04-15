!> Adds PFASST hooks containing callbacks to C functions
!!

module cpf_hooks
    use pfasst
    use iso_c_binding
    implicit none

!    interface
!        subroutine hook_cb()
!        end subroutine hook_cb
!    end interface
!
!    ! encapsulates the pointer so Fortran will allow an array
!    type :: hook_cb_type
!        procedure(hook_cb), pointer :: cb
!    end type hook_cb_type
!
!    type(hook_cb_type) :: hook_cbs(PF_MAX_HOOK)

contains

    ! TODO: double check me
!    subroutine pre_predictor_cb()
!        call hook_cbs(PF_PRE_PREDICTOR)%cb()
!    end subroutine
!
!    subroutine post_predictor_cb()
!        call hook_cbs(PF_POST_PREDICTOR)%cb
!    end subroutine
!
!    subroutine pre_iteration_cb()
!        call hook_cbs(PF_PRE_ITERATION)%cb
!    end subroutine
!
!    subroutine post_iteration_cb()
!        call hook_cbs(PF_POST_ITERATION)%cb
!    end subroutine
!
!    subroutine pre_sweep_cb()
!        call hook_cbs(PF_PRE_SWEEP)%cb
!    end subroutine
!
!    subroutine post_sweep_cb()
!        call hook_cbs(PF_POST_SWEEP)%cb
!    end subroutine
!
!    subroutine pre_block_cb()
!        call hook_cbs(PF_PRE_BLOCK)%cb
!    end subroutine
!
!    subroutine post_block_cb()
!        call hook_cbs(PF_POST_BLOCK)%cb
!    end subroutine
!
!    subroutine pre_interp_all_cb()
!        call hook_cbs(PF_PRE_INTERP_ALL)%cb
!    end subroutine
!
!    subroutine post_interp_all_cb()
!        call hook_cbs(PF_POST_INTERP_ALL)%cb
!    end subroutine
!
!    subroutine pre_interp_q0_cb()
!        call hook_cbs(PF_PRE_INTERP_Q0)%cb
!    end subroutine
!
!    subroutine post_interp_q0_cb()
!        call hook_cbs(PF_POST_INTERP_Q0)%cb
!    end subroutine
!
!    subroutine pre_restrict_all_cb()
!        call hook_cbs(PF_PRE_RESTRICT_ALL)%cb
!    end subroutine
!
!    subroutine post_restrict_all_cb()
!        call hook_cbs(PF_POST_RESTRICT_ALL)%cb
!    end subroutine
!
!    subroutine pre_convergence_cb()
!        call hook_cbs(PF_PRE_CONVERGENCE)%cb
!    end subroutine
!
!    subroutine post_convergence_cb()
!        call hook_cbs(PF_POST_CONVERGENCE)%cb
!    end subroutine
!
!    subroutine post_all_cb()
!        call hook_cbs(PF_POST_ALL)%cb
!    end subroutine

    subroutine cpf_add_interop_hook(pf, level_index, hook, c_fun)
        type(pf_pfasst_t), intent(inout) :: pf            !! main pfasst structure
        integer(c_int),    intent(in)    :: level_index   !! which pfasst level to add hook
        integer(c_int),    intent(in)    :: hook          !! which hook to add
        type(c_funptr)                   :: c_fun         !! function pointer to c callback
        procedure(pf_hook_p), pointer :: procptr

        call c_f_procpointer(c_fun, procptr)
        call pf_add_hook(pf, level_index, hook, procptr)
    end subroutine




end module cpf_hooks