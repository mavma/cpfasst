project(cpfasst_ex3)
cmake_minimum_required(VERSION 3.16)

# libfftpack
set(LIBFFTPACK_DIR ${CMAKE_CURRENT_SOURCE_DIR}/libfftpack)
add_custom_target(libfftpack_make
        WORKING_DIRECTORY ${LIBFFTPACK_DIR}
        COMMAND make
        BYPRODUCTS ${LIBFFTPACK_DIR}/libfftpack.a
        COMMENT "Building libfftpack"
        VERBATIM)
add_library(libfftpack::libfftpack STATIC IMPORTED)
target_include_directories(libfftpack::libfftpack INTERFACE ${LIBFFTPACK_DIR})
set_target_properties(libfftpack::libfftpack PROPERTIES IMPORTED_LOCATION ${LIBFFTPACK_DIR}/libfftpack.a)
add_dependencies(libfftpack::libfftpack libfftpack_make)

# EX3_adv_diff
add_executable(EX3_adv_diff
        src/encap.c
        src/fft_tool.c
        src/level.c
        src/main.c
        src/probin.c
        src/shared.c
        src/solution.c
        src/sweeper.c
        src/utils.c)
target_link_libraries(EX3_adv_diff cpfasst libfftpack::libfftpack)
target_compile_options(EX3_adv_diff PRIVATE -std=gnu17 -Wall -Wpedantic -Wextra -Wno-unused-parameter)
