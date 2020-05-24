MPI_BIN ?= /opt/mpich/bin

CC = $(MPI_BIN)/mpicc
FC = $(MPI_BIN)/mpif90
AR = ar rcs

DEBUG = TRUE

# C compiler & linker flags
CFLAGS = -I$(CPFASST)/include -O3
CLDFLAGS = -L$(CPFASST)/lib -lcpfasst -L$(LIBPFASST)/lib -lpfasst -lgfortran -lquadmath -lm -ldl

# Fortran compiler & linker flags
FFLAGS = -ILibPFASST/include -cpp -O3
FFLAGS += -fcheck=all -fbacktrace -ffpe-trap=invalid,zero,overflow -fbounds-check -fimplicit-none -ffree-line-length-none
FLDFLAGS = -LLibPFASST/lib -lpfasst

# MPI linking flags
# Uncomment next line for OpenMPI
# FMPIFLAGS += $(shell mpif90 --showme:link)
# Uncomment next line for mpich
FMPIFLAGS += $(wordlist 2, 999, $(shell $(FC) -link_info))

# debug flags
ifeq ($(DEBUG),TRUE)
CFLAGS += -g -O0
FFLAGS += -g -O0
endif
