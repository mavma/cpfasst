cpfasst_dir ?= $(PWD)
libpfasst_dir ?= $(cpfasst_dir)/LibPFASST

MPI_BIN ?= /opt/mpich/bin

CC = $(MPI_BIN)/mpicc
FC = $(MPI_BIN)/mpif90
LD = $(MPI_BIN)/mpicc
AR = ar rcs

GCC10 ?= TRUE # enables gcc10-only flag to allow compiling LibPFASST

DEBUG = TRUE

# C compiler & linker flags
CFLAGS = -I$(cpfasst_dir)/include -O3
CLDFLAGS = -L$(cpfasst_dir)/build -lcpfasst -L$(libpfasst_dir)/lib -lpfasst -lgfortran -lquadmath -lm -ldl

# Fortran compiler & linker flags
FFLAGS = -I$(libpfasst_dir)/include -cpp -O3
FFLAGS += -fcheck=all -fbacktrace -ffpe-trap=invalid,zero,overflow -fbounds-check -fimplicit-none -ffree-line-length-none
FLDFLAGS = -L$(libpfasst_dir)/lib -lpfasst

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

# control verbosity
V ?= 0
ifeq ($(V),0)
	CC_MSG = @echo "Compiling $<...";
	LD_MSG = @echo "Linking $<...";
	AR_MSG = @echo "Creating archive $@...";
endif
CCv = $(CC_MSG)$(CC)
FCv = $(CC_MSG)$(FC)
LDv = $(LD_MSG)$(LD)
ARv = $(AR_MSG)$(AR)

$(info $$V is [${V}])
$(info $$CCv is [${CCv}])