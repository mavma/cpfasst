module cpf_encap
    use pfasst
    use cpf_utils
    use iso_c_binding
    implicit none

    interface
        ! Interoperable interfaces to C callback functions that handle encapsulated data
        ! Must match C declarations in header cpf_encap.h

        subroutine cpf_factory_create_cb(data, level_index) bind(C)
            import :: c_ptr, c_int
            type(c_ptr),    intent(inout)     :: data
            integer(c_int), intent(in), value :: level_index
        end subroutine

        subroutine cpf_factory_destroy_cb(data) bind(C)
            import :: c_ptr
            type(c_ptr), intent(in), value :: data
        end subroutine

        subroutine cpf_encap_setval_cb(data, val) bind(C)
            import :: c_ptr, c_double
            type(c_ptr),    intent(in), value :: data
            real(c_double), intent(in), value :: val
        end subroutine

        subroutine cpf_encap_copy_cb(dst, src) bind(C)
            import :: c_ptr
            type(c_ptr), intent(in), value :: dst
            type(c_ptr), intent(in), value :: src
        end subroutine cpf_encap_copy_cb

        function cpf_encap_norm_cb(data) result(norm) bind(C)
            import :: c_ptr, c_double
            type(c_ptr), intent(in), value :: data
            real(c_double)                 :: norm
        end function cpf_encap_norm_cb

        subroutine cpf_encap_axpy_cb (y, a, x) bind(C)
            import :: c_ptr, c_double
            type(c_ptr),    intent(in), value :: y
            type(c_ptr),    intent(in), value :: x
            real(c_double), intent(in), value :: a
        end subroutine cpf_encap_axpy_cb

        subroutine cpf_encap_eprint_cb (y) bind(C)
            import :: c_ptr
            type(c_ptr), intent(in), value :: y
        end subroutine cpf_encap_eprint_cb
    end interface

    type, extends(pf_factory_t) :: cpf_factory
    contains
        procedure :: create_single  => cpf_factory_create_single
        procedure :: create_array   => cpf_factory_create_array
        procedure :: destroy_single => cpf_factory_destroy_single
        procedure :: destroy_array  => cpf_factory_destroy_array
    end type cpf_factory

    type, extends(pf_encap_t) :: cpf_encap_t
        type(c_ptr) :: data = C_NULL_PTR ! C pointer to encapsulated data
    contains
        procedure :: setval => cpf_encap_setval
        procedure :: copy   => cpf_encap_copy
        procedure :: norm   => cpf_encap_norm
        procedure :: pack   => cpf_encap_pack
        procedure :: unpack => cpf_encap_unpack
        procedure :: axpy   => cpf_encap_axpy
        procedure :: eprint => cpf_encap_eprint
    end type cpf_encap_t

contains

    ! Helper function to allocate data for a cpf_encap_t through callback
    subroutine cpf_encap_build(encap, level_index)
        class(pf_encap_t), intent(inout) :: encap
        integer,           intent(in)    :: level_index

        select type (encap)
        class is (cpf_encap_t)
            call cpf_factory_create_cb(encap%data, level_index)
        end select
    end subroutine cpf_encap_build

    ! Allocate one encap
    subroutine cpf_factory_create_single(this, x, level_index, lev_shape)
        class(cpf_factory), intent(inout)              :: this
        class(pf_encap_t),  intent(inout), allocatable :: x
        integer,            intent(in)                 :: level_index
        integer,            intent(in)                 :: lev_shape(:)
        integer :: ierr

        allocate(cpf_encap_t::x, stat=ierr)
        if (ierr /=0) call oops(__FILE__,__LINE__,'Internal error: Failed to allocate data', ierr)
        call cpf_encap_build(x, level_index)
    end subroutine cpf_factory_create_single

    ! Allocate an array of encaps
    subroutine cpf_factory_create_array(this, x, n, level_index,lev_shape)
        class(cpf_factory), intent(inout)              :: this
        class(pf_encap_t),  intent(inout), allocatable :: x(:)
        integer,            intent(in)                 :: n
        integer,            intent(in)                 :: level_index
        integer,            intent(in)                 :: lev_shape(:)
        integer :: i, ierr

        allocate(cpf_encap_t::x(n),stat=ierr)
        if (ierr /=0) call oops(__FILE__,__LINE__,'Internal error: Failed to allocate data', ierr)
        do i = 1, n
            call cpf_encap_build(x(i), level_index)
        end do
    end subroutine cpf_factory_create_array

    ! Deallocate encapsulated cpf_encap_t
    subroutine cpf_encap_destroy(encap)
        class(pf_encap_t), intent(inout) :: encap

        select type (encap)
        class is (cpf_encap_t)
            call cpf_factory_destroy_cb(encap%data)
            encap%data = C_NULL_PTR
        end select
    end subroutine cpf_encap_destroy

    ! Destroy a single encap
    subroutine cpf_factory_destroy_single(this, x)
        class(cpf_factory), intent(inout)              :: this
        class(pf_encap_t),  intent(inout), allocatable :: x

        call cpf_encap_destroy(x)
        deallocate(x)
    end subroutine cpf_factory_destroy_single

    ! Destroy an array of encaps
    subroutine cpf_factory_destroy_array(this, x)
        class(cpf_factory), intent(inout)              :: this
        class(pf_encap_t),  intent(inout), allocatable :: x(:)
        integer :: i

        do i = 1,size(x)
            call cpf_encap_destroy(x(i))
        end do
        deallocate(x)
    end subroutine cpf_factory_destroy_array

    ! Set array to a scalar value.
    subroutine cpf_encap_setval(this, val, flags)
        class(cpf_encap_t), intent(inout)        :: this
        real(pfdp),         intent(in)           :: val
        integer,            intent(in), optional :: flags

        call cpf_encap_setval_cb(this%data, val)
    end subroutine cpf_encap_setval

    ! Copy an array
    subroutine cpf_encap_copy(this, src, flags)
        class(cpf_encap_t), intent(inout)        :: this
        class(pf_encap_t),  intent(in)           :: src
        integer,            intent(in), optional :: flags

        select type(src)
        type is (cpf_encap_t)
            call cpf_encap_copy_cb(this%data, src%data)
        class default
            call oops(__FILE__, __LINE__, 'Internal error: cpf_encap_copy was called with invalid type')
        end select
    end subroutine cpf_encap_copy

    ! Pack into a flat array for sending
    subroutine cpf_encap_pack(this, z, flags)
        class(cpf_encap_t), intent(in)           :: this
        real(pfdp),         intent(out)          :: z(:)
        integer,            intent(in), optional :: flags
        real(pfdp), pointer :: fptr(:)

        call c_f_pointer(this%data, fptr, [size(z)])
        z = fptr
    end subroutine cpf_encap_pack

    ! Unpack data after receiving
    subroutine cpf_encap_unpack(this, z, flags)
        class(cpf_encap_t), intent(inout)        :: this
        real(pfdp),         intent(in)           :: z(:)
        integer,            intent(in), optional :: flags
        real(pfdp), pointer :: fptr(:)
        
        call c_f_pointer(this%data, fptr, [size(z)])
        fptr = z
    end subroutine cpf_encap_unpack

    ! Compute norm
    function cpf_encap_norm(this, flags) result (norm)
        class(cpf_encap_t), intent(in)           :: this
        integer,            intent(in), optional :: flags
        real(pfdp) :: norm

        norm = cpf_encap_norm_cb(this%data)
    end function cpf_encap_norm

    ! Compute y=a*x+y where a is a scalar and x and y are cpf_encap_t
    subroutine cpf_encap_axpy(this, a, x, flags)
        class(cpf_encap_t), intent(inout)        :: this
        class(pf_encap_t),  intent(in)           :: x
        real(pfdp),         intent(in)           :: a
        integer,            intent(in), optional :: flags

        select type(x)
        type is (cpf_encap_t)
            call cpf_encap_axpy_cb(this%data, a, x%data)
        class default
            call oops(__FILE__, __LINE__, 'Internal error: cpf_encap_axpy was called with invalid type')
        end select
    end subroutine cpf_encap_axpy

    ! Print data to standard output
    subroutine cpf_encap_eprint(this,flags)
        class(cpf_encap_t), intent(inout)        :: this
        integer,            intent(in), optional :: flags

        call cpf_encap_eprint_cb(this%data)
    end subroutine cpf_encap_eprint

    ! Helper function to cast an abstract encap to cpf_encap_t
    function cast_to_cpf_encap(encap) result(cpf_ptr)
        class(pf_encap_t), intent(in), target :: encap
        type(cpf_encap_t), pointer :: cpf_ptr

        select type(encap)
        type is (cpf_encap_t)
            cpf_ptr => encap
        end select
    end function cast_to_cpf_encap

end module cpf_encap