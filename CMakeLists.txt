project(cpfasst)
cmake_minimum_required(VERSION 3.16)

if(NOT CMAKE_BUILD_TYPE AND NOT CMAKE_CONFIGURATION_TYPES)
    set(CMAKE_BUILD_TYPE Debug) # default build type
endif()

enable_language(Fortran)
# use environment variable MPI_HOME to choose an MPI installation
find_package(MPI REQUIRED)

include(LibPFASST.cmake)

add_library(cpfasst
        src/cpf_encap.f90
        src/cpf_imex_sweeper.f90
        src/cpf_interface.f90
        src/cpf_level.f90
        src/cpf_main.f90
        src/cpf_parameters.f90
        src/cpf_utils.f90)
target_include_directories(cpfasst INTERFACE include)
target_link_libraries(cpfasst PUBLIC libpfasst::libpfasst MPI::MPI_Fortran)

set(FORTRAN_DEBUG_FLAGS -fcheck=all -fbacktrace -ffpe-trap=invalid,zero,overflow
        -fbounds-check -fimplicit-none -ffree-line-length-none)
target_compile_options(cpfasst PRIVATE -cpp -ffree-line-length-none $<$<CONFIG:Debug>:${FORTRAN_DEBUG_FLAGS}>)

add_subdirectory(examples/EX3_adv_diff)
