CPFASST_DIR ?= $(PWD)
LIBPFASST_DIR := $(CPFASST_DIR)/LibPFASST

CC := mpicc
FC := mpif90
LD := mpicc
AR = ar rcs

# enables gcc10-only flag to allow compiling LibPFASST
GCC10 ?= TRUE
# supported: mpich, openmpi
MPI ?= mpich

# C compiler & linker flags
CFLAGS =
CLDFLAGS := -L$(LIBPFASST_DIR)/lib -lpfasst -lgfortran -lquadmath -lm -ldl

# Fortran compiler & linker flags
FFLAGS := -I$(LIBPFASST_DIR)/include -cpp
FFLAGS += -fcheck=all -fbacktrace -ffpe-trap=invalid,zero,overflow -fbounds-check -fimplicit-none -ffree-line-length-none
FLDFLAGS := -L$(LIBPFASST_DIR)/lib -lpfasst

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
CFLAGS += -O3
FFLAGS += -O3
endif

# strict checks on memory access - does not work under gdb
ASAN ?= 0
ifeq ($(ASAN),1)
CFLAGS += -fsanitize=address
FFLAGS += -fsanitize=address
CLDFLAGS += -fsanitize=address
FLDFLAGS += -fsanitize=address
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