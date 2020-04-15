!> Encapsulation with C data storage and callback functions
!!

module cpf_encap
    use pfasst
    use iso_c_binding
    implicit none

    !>  Type to create and destroy the local data encapsulation
    type, extends(pf_factory_t) :: cpf_factory
    contains
        procedure :: create_single  => cpf_create_single
        procedure :: create_array  => cpf_create_array
        procedure :: destroy_single => cpf_destroy_single
        procedure :: destroy_array => cpf_destroy_array
    end type cpf_factory

    !>  Type to extend the abstract encap and set procedure pointers
    type, extends(pf_encap_t) :: cpf_encap_t
        type(c_ptr) :: data ! C pointer to encapsulated data
        real(pfdp) :: y   !  The scalar value FIXME: remove
    contains
        procedure :: setval => cpf_setval
        procedure :: copy => cpf_copy
        procedure :: norm => cpf_norm
        procedure :: pack => cpf_pack
        procedure :: unpack => cpf_unpack
        procedure :: axpy => cpf_axpy
        procedure :: eprint => cpf_eprint
    end type cpf_encap_t

    !>  Interoperable interfaces to C functions that handle encapsulated data
    interface
        subroutine factory_create_cb(data, level_index, lev_shape, lev_shape_len) bind(C)
            import :: c_ptr, c_int
            type(c_ptr),    intent(out) :: data
            integer(c_int), intent(in)  :: level_index
            integer(c_int), intent(in)  :: lev_shape(:)
            integer(c_int), intent(in)  :: lev_shape_len
        end subroutine
        subroutine factory_destroy_cb(data) bind(C)
            import :: c_ptr
            type(c_ptr), intent(in)     :: data
        end subroutine
        subroutine encap_setval_cb(data, val, flags) bind(C)
            import :: c_ptr, c_double, c_int
            type(c_ptr),    intent(in)           :: data
            real(c_double), intent(in)           :: val
            integer(c_int), intent(in), optional :: flags
        end subroutine
        subroutine encap_copy_cb(data, src, flags) bind(C)
            import :: c_ptr, c_int
            type(c_ptr),    intent(in)           :: data
            type(c_ptr),    intent(in)           :: src
            integer(c_int), intent(in), optional :: flags
        end subroutine encap_copy_cb
        function encap_norm_cb(data, flags) result(norm) bind(C)
            import :: c_ptr, c_double, c_int
            type(c_ptr),    intent(in)           :: data
            integer(c_int), intent(in), optional :: flags
            real(c_double)                       :: norm
        end function encap_norm_cb
        subroutine encap_axpy_cb (y, a, x, flags) bind(C)
            import :: c_ptr, c_double, c_int
            type(c_ptr),    intent(in)           :: y
            type(c_ptr),    intent(in)           :: x
            real(c_double), intent(in)           :: a
            integer(c_int), intent(in), optional :: flags
        end subroutine encap_axpy_cb
        subroutine encap_eprint_cb (y, flags) bind(C)
            import :: c_ptr, c_int
            type(c_ptr),    intent(in)           :: y
            integer(c_int), intent(in), optional :: flags
        end subroutine encap_eprint_cb
    end interface

contains

    !>  Helper subroutine to allocate data for cpf_encap_t
    subroutine cpf_encap_build(encap, level_index, lev_shape)
        class(pf_encap_t),     intent(inout) ::  encap
        integer,               intent(in   ) ::  level_index
        integer,               intent(in   ) ::  lev_shape(:)
        select type (encap)
        class is (cpf_encap_t)
            call factory_create_cb(encap%data, level_index, lev_shape, size(lev_shape))
        end select
    end subroutine cpf_encap_build

    !>  Subroutine to allocate one encap
    subroutine cpf_create_single(this, x, level_index, lev_shape)
        class(cpf_factory),    intent(inout)              :: this
        class(pf_encap_t),     intent(inout), allocatable :: x
        integer,               intent(in   ) ::  level_index
        integer,               intent(in   ) ::  lev_shape(:)
        integer :: ierr
        allocate(cpf_encap_t::x,stat=ierr)
        ! if (ierr /=0) call pf_stop(__FILE__,__LINE__,'allocate fail, error=',ierr) FIXME
        call cpf_encap_build(x, level_index, lev_shape)
    end subroutine cpf_create_single

    !> Subroutine to create an array of encaps
    subroutine cpf_create_array(this, x, n, level_index,lev_shape)
        class(cpf_factory),    intent(inout)              :: this
        class(pf_encap_t),     intent(inout), allocatable :: x(:)
        integer,               intent(in   )              :: n  ! size of array to build
        integer,               intent(in   ) ::  level_index
        integer,               intent(in   ) ::  lev_shape(:)
        integer :: i, ierr
        allocate(cpf_encap_t::x(n),stat=ierr)
        ! if (ierr /=0) call pf_stop(__FILE__,__LINE__,'allocate fail, error=',ierr) FIXME
        do i = 1, n
            call cpf_encap_build(x(i), level_index, lev_shape)
        end do
    end subroutine cpf_create_array

    !>  Helper subroutine to deallocate encapsulated cpf_encap_t
    subroutine cpf_encap_destroy(encap)
        class(pf_encap_t),     intent(inout) ::  encap
        select type (encap)
        class is (cpf_encap_t)
            call factory_destroy_cb(encap%data)
        end select
    end subroutine cpf_encap_destroy

    !> Subroutine to destroy a single array encap
    subroutine cpf_destroy_single(this, x)
        class(cpf_factory),     intent(inout)              :: this
        class(pf_encap_t),      intent(inout), allocatable :: x
        call cpf_encap_destroy(x)
        deallocate(x)
    end subroutine cpf_destroy_single

    !> Subroutine to destroy an array of arrays
    subroutine cpf_destroy_array(this, x)
        class(cpf_factory),     intent(inout)              :: this
        class(pf_encap_t),      intent(inout), allocatable :: x(:)
        integer :: i
        do i = 1,size(x)
            call cpf_encap_destroy(x(i))
        end do
        deallocate(x)
    end subroutine cpf_destroy_array

    !> Subroutine to set array to a scalar  value.
    subroutine cpf_setval(this, val, flags)
        class(cpf_encap_t), intent(inout)           :: this
        real(pfdp),         intent(in)              :: val
        integer,            intent(in), optional    :: flags
        call encap_setval_cb(this%data, val, flags)
        this%y = val ! FIXME remove me
    end subroutine cpf_setval

    !> Subroutine to copy an array
    subroutine cpf_copy(this, src, flags)
        class(cpf_encap_t), intent(inout)           :: this
        class(pf_encap_t),  intent(in)              :: src
        integer,            intent(in), optional    :: flags
        select type(src)
        type is (cpf_encap_t)
            call encap_copy_cb(this%data, src%data, flags)
            this%y = src%y ! FIXME remove me
        class default
            stop "TYPE ERROR"
        end select
    end subroutine cpf_copy

    !> Subroutine to pack into a flat array for sending
    subroutine cpf_pack(this, z, flags)
        class(cpf_encap_t), intent(in)              :: this
        real(pfdp),         intent(out)             :: z(:)
        integer,            intent(in), optional    :: flags
        real(pfdp), pointer :: fptr(:)
        call c_f_pointer(this%data, fptr, [size(z)])
        z = fptr
    end subroutine cpf_pack

    !> Subroutine to unpack  after receiving
    subroutine cpf_unpack(this, z, flags)
        class(cpf_encap_t), intent(inout)           :: this
        real(pfdp),         intent(in)              :: z(:)
        integer,            intent(in), optional    :: flags
        real(pfdp), pointer :: fptr(:)
        call c_f_pointer(this%data, fptr, [size(z)])
        fptr = z
        this%y = z(1)
    end subroutine cpf_unpack

    !> Subroutine to define the norm of the array (here the abs value)
    function cpf_norm(this, flags) result (norm2)
        class(cpf_encap_t), intent(in   ) :: this
        integer,     intent(in   ), optional :: flags
        real(pfdp) :: normf, norm2
        normf = abs(this%y) ! FIXME remove
        norm2 = encap_norm_cb(this%data, flags)
    end function cpf_norm

    !> Subroutine to compute y = a x + y where a is a scalar and x and y are arrays
    subroutine cpf_axpy(this, a, x, flags)
        class(cpf_encap_t), intent(inout)           :: this
        class(pf_encap_t),  intent(in   )           :: x
        real(pfdp),         intent(in   )           :: a
        integer,            intent(in   ), optional :: flags
        select type(x)
        type is (cpf_encap_t)
            this%y = a * x%y + this%y ! FIXME remove me
            call encap_axpy_cb(this%data, a, x%data, flags)
        class default
            stop "TYPE ERROR"
        end select
    end subroutine cpf_axpy

    !>  Subroutine to print the array to the screen (mainly for debugging purposes)
    subroutine cpf_eprint(this,flags)
        class(cpf_encap_t), intent(inout) :: this
        integer,           intent(in   ), optional :: flags
        print *, this%y
        ! call encap_eprint_cb(this%data, flags) FIXME restore
    end subroutine cpf_eprint

    !  Helper function to cast an abstract encap to the cpf_encap_t
    function cast_as_cpf(encap_polymorph) result(cpf_obj)
        class(pf_encap_t), intent(in), target :: encap_polymorph
        type(cpf_encap_t), pointer :: cpf_obj

        select type(encap_polymorph)
        type is (cpf_encap_t)
            cpf_obj => encap_polymorph
        end select
    end function cast_as_cpf

end module cpf_encap