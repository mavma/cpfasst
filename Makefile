MPICH_BIN = /opt/mpich/bin

CSRC = sweeper.c
FSRC = probin.f90 encap.f90 level.f90 ex2sweeper.f90 hooks.f90 cpf_imex_sweeper.f90 cpf_interface.f90
BUILDDIR = build
SRCDIR = src

CC = $(MPICH_BIN)/mpicc
CFLAGS = -g -O0 -I.
CLDFLAGS += -LLibPFASST/lib -lpfasst
CLDFLAGS += -lgfortran -lquadmath -lm -ldl

FC = $(MPICH_BIN)/mpif90
FFLAGS = -g -O0 -ILibPFASST/include
FFLAGS += -fcheck=all -fbacktrace -ffpe-trap=invalid,zero,overflow -fbounds-check -fimplicit-none -ffree-line-length-none
FLDFLAGS += -LLibPFASST/lib -lpfasst

# OpenMPI
# FMPIFLAGS += $(shell mpif90 --showme:link)
# mpich
FMPIFLAGS += $(wordlist 2, 999, $(shell $(FC) -link_info))
# Intel MPI
# FMPIFLAGS += $(wordlist 2, 999, $(shell mpiifort -show))
# CLDFLAGS += -nofor_main

OBJ  = $(addprefix $(BUILDDIR)/,$(FSRC:.f90=.o) $(CSRC:.c=.o))

all: cmain

$(BUILDDIR)/%.o: $(SRCDIR)/%.c
	@mkdir -p $(BUILDDIR)
	$(CC) -c -o $@ $< $(CFLAGS)

$(BUILDDIR)/%.o: $(SRCDIR)/%.f90
	@mkdir -p $(BUILDDIR)
	$(FC) -c -o $@ -J$(BUILDDIR) $< $(FFLAGS)

cmain: $(BUILDDIR)/cmain.o $(OBJ)
	$(CC) -o $@ $^ $(CLDFLAGS) $(FMPIFLAGS)

$(OBJ): libpfasst

libpfasst:
	cd LibPFASST; $(MAKE) DEBUG=TRUE MKVERBOSE=TRUE FC=$(FC) CC=$(CC)

clean:
	\rm -rf build
	cd LibPFASST; $(MAKE) clean