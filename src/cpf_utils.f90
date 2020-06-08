! Utility functions for C/Fortran interoperability
module cpf_utils
    use iso_c_binding

contains

    ! Convert C string into Fortran string padded with empty spaces
    subroutine c_f_string(c_string, f_string)
        character(c_char), intent(in)  :: c_string(:)
        character(len=*),  intent(out) :: f_string
        integer :: c_strlen, i

        if(size(c_string) /= len(f_string)) call oops(__FILE__, __LINE__, 'Mismatched lengths in string conversion')
        c_strlen = findloc(c_string, C_NULL_CHAR, 1)
        if(c_strlen == 0) call oops(__FILE__, __LINE__, 'C string must be null-terminated')
        do i = 1, c_strlen
            f_string(i:i) = c_string(i)
        end do
        f_string(c_strlen:) = ' '
    end subroutine c_f_string

    ! Convert Fortran string padded with empty spaces into  C string
    subroutine f_c_string(f_string, c_string)
        character(len=*),  intent(in)  :: f_string
        character(c_char), intent(out) :: c_string(:)
        integer :: f_strlen, i

        if(size(c_string) /= len(f_string)) call oops(__FILE__, __LINE__, 'Mismatched lengths in string conversion')
        f_strlen = len_trim(f_string)
        if(f_strlen == len(f_string)) call oops(__FILE__, __LINE__, 'Fortran string is too long for conversion')
        do i = 1, f_strlen
            c_string(i) = f_string(i:i)
        end do
        c_string(f_strlen+1) = C_NULL_CHAR
    end subroutine f_c_string

    subroutine oops(file, line, msg, err)
        use iso_fortran_env, only: error_unit
        character(len=*), intent(in)           :: file
        integer,          intent(in)           :: line
        character(len=*), intent(in)           :: msg
        integer,          intent(in), optional :: err

        write(error_unit,*) 'Error in CPFASST interface'
        write(error_unit,*) 'File: ', file
        write(error_unit,*) 'Line: ', line
        write(error_unit,*) trim(msg)
        if(present(err)) write(error_unit,*) 'Error code:', err
        call exit(-1)
    end subroutine oops
end module cpf_utils

