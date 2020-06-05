CPFASST_DIR ?= $(PWD)
LIBPFASST_DIR := $(CPFASST_DIR)/LibPFASST

MPI_BIN ?= /opt/mpich/bin

CC := $(MPI_BIN)/mpicc
FC := $(MPI_BIN)/mpif90
LD := $(MPI_BIN)/mpicc
AR = ar rcs

GCC10 ?= TRUE # enables gcc10-only flag to allow compiling LibPFASST

# C compiler & linker flags
CFLAGS =
CLDFLAGS := -L$(LIBPFASST_DIR)/lib -lpfasst -lgfortran -lquadmath -lm -ldl

# Fortran compiler & linker flags
FFLAGS := -I$(LIBPFASST_DIR)/include -cpp
FFLAGS += -fcheck=all -fbacktrace -ffpe-trap=invalid,zero,overflow -fbounds-check -fimplicit-none -ffree-line-length-none
FLDFLAGS := -L$(LIBPFASST_DIR)/lib -lpfasst

# MPI linking flags
# Uncomment next line for OpenMPI
# FMPIFLAGS += $(shell mpif90 --showme:link)
# Uncomment next line for mpich
FMPIFLAGS += $(wordlist 2, 999, $(shell $(FC) -link_info))

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