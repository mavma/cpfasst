# CMake target for LibPFASST

find_package(MPI REQUIRED)

set(LIBPFASST_ROOT ${CMAKE_CURRENT_SOURCE_DIR}/LibPFASST/)
set(LIBPFASST_LIB ${LIBPFASST_ROOT}/lib/libpfasst.a)

# LibPFASST is compiled using its own Makefile, but sources are listed here for the benefit of CMake-based IDEs
set(LIBPFASST_SOURCES
        src/pfasst.f90
        src/pf_comm.f90
        src/pf_dtype.f90
        src/pf_fft.f90
        src/pf_hooks.f90
        src/pf_interpolate.f90
        src/pf_parallel.f90
        src/pf_parareal.f90
        src/pf_parallel_oc.f90
        src/pf_pfasst.f90
        src/pf_quadrature.f90
        src/pf_restrict.f90
        src/pf_results.f90
        src/pf_rkstepper.f90
        src/pf_erkstepper.f90
        src/pf_solutions.f90
        src/pf_stop.f90
        src/pf_timer.f90
        src/pf_utils.f90
        src/pf_ham_sys_encap.f90
        src/pf_ndarray_encap.f90
        src/pf_ndarray_oc_encap.f90
        src/pf_ndsysarray_encap.f90
        src/pf_zndsysarray_encap.f90
        src/pf_zndarray_encap.f90
        src/pf_exp_sweeper.f90
        src/pf_fexp_sweeper.f90
        src/pf_imex_sweeper.f90
        src/pf_imexR_sweeper.f90
        src/pf_imexQ_oc_sweeper.f90
        src/pf_imk_sweeper.f90
        src/pf_magpicard_sweeper.f90
        src/pf_misdcQ_sweeper.f90
        src/pf_misdcQ_oc_sweeper.f90
        src/pf_verlet_sweeper.f90
        src/pf_fexp_sweeper.f90)
list(TRANSFORM LIBPFASST_SOURCES PREPEND ${LIBPFASST_ROOT})

execute_process(COMMAND ${MPI_C_COMPILER} -dumpfullversion OUTPUT_VARIABLE MPICC_VERSION)
if(${MPICC_VERSION} VERSION_GREATER_EQUAL 10)
    # gfortran > 10 requires an additional flag to compile LibPFASST, but earlier versions do not recognize it
    list(APPEND EXTRA_MAKE_ARGS "FFLAGS_EXTRA=-fallow-argument-mismatch")
endif()
if(${CMAKE_VERBOSE_MAKEFILE})
    list(APPEND EXTRA_MAKE_ARGS "MKVERBOSE=TRUE")
endif()

set(LIBPFASST_MAKE_ARGS
        FC=${MPI_Fortran_COMPILER}
        CC=${MPI_C_COMPILER}
        $<$<CONFIG:Debug>:DEBUG=TRUE>
        ${EXTRA_MAKE_ARGS})
add_custom_target(libpfasst_make
        WORKING_DIRECTORY ${LIBPFASST_ROOT}
        COMMAND make ${LIBPFASST_MAKE_ARGS}
        SOURCES ${LIBPFASST_SOURCES}
        BYPRODUCTS ${LIBPFASST_LIB}
        COMMENT "Building LibPFASST"
        VERBATIM COMMAND_EXPAND_LISTS)
set_target_properties(libpfasst_make PROPERTIES ADDITIONAL_CLEAN_FILES
        "${LIBPFASST_ROOT}/build;${LIBPFASST_ROOT}/include")
file(MAKE_DIRECTORY ${LIBPFASST_ROOT}/include) # appease CMake

add_library(libpfasst::libpfasst STATIC IMPORTED)
set_target_properties(libpfasst::libpfasst PROPERTIES IMPORTED_LOCATION ${LIBPFASST_LIB})
target_include_directories(libpfasst::libpfasst INTERFACE ${LIBPFASST_ROOT}/include)
target_link_libraries(libpfasst::libpfasst INTERFACE MPI::MPI_Fortran)
add_dependencies(libpfasst::libpfasst libpfasst_make)