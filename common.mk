CPFASST_DIR ?= $(PWD)
LIBPFASST_DIR := $(CPFASST_DIR)/LibPFASST

CC := mpicc
FC := mpifort
LD := mpicc
AR = ar rcs

# enables gcc10-only flag to allow compiling LibPFASST
GCC10 ?= TRUE
# supported: mpich, openmpi
MPI ?= mpich

# C compiler flags
CFLAGS := -std=gnu17 -Wall -Wpedantic -Wextra -Wno-unused-parameter
# Fortran compiler flags
FFLAGS := -I$(LIBPFASST_DIR)/include -cpp
FFLAGS += -fcheck=all -fbacktrace -ffpe-trap=invalid,zero,overflow -fbounds-check -fimplicit-none -ffree-line-length-none
# Linker flags
LDFLAGS := -L$(LIBPFASST_DIR)/lib -lpfasst -lgfortran -lquadmath -lm -ldl

# MPI linking flags
ifeq ($(MPI),mpich)
FMPIFLAGS += $(wordlist 2, 999, $(shell $(FC) -link_info))
else ifeq ($(MPI),openmpi)
FMPIFLAGS += $(shell mpif90 --showme:link)
endif

# TODO: change default
# debug flags
DEBUG ?= TRUE
ifeq ($(DEBUG),TRUE)
CFLAGS += -g -O0
FFLAGS += -g -O0
else
CFLAGS += -O3 -flto
FFLAGS += -O3 -flto
LDFLAGS += -flto
endif

# strict checks on memory access - does not work under gdb
ASAN ?= 0
ifeq ($(ASAN),1)
CFLAGS += -fsanitize=address
FFLAGS += -fsanitize=address
LDFLAGS += -fsanitize=address
endif

# control verbosity
V ?= 0
ifeq ($(V),0)
CC_MSG = @echo "Compiling $<...";
LD_MSG = @echo "Linking $@...";
AR_MSG = @echo "Creating archive $@...";
endif
CCv = $(CC_MSG)$(CC)
FCv = $(CC_MSG)$(FC)
LDv = $(LD_MSG)$(LD)
ARv = $(AR_MSG)$(AR)