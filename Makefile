MPICH_BIN = /opt/mpich/bin

SRC =
FSRC = probin.f90 level.f90 sweeper.f90 cpf_imex_sweeper.f90 interface.f90
BUILDDIR = build
SRCDIR = .

CC = $(MPICH_BIN)/mpicc
CFLAGS = -g -Og -I.
CLDFLAGS += -LLibPFASST/lib -lpfasst
CLDFLAGS += -lgfortran -lquadmath

FC = $(MPICH_BIN)/mpif90

# OpenMPI
# FMPIFLAGS += $(shell mpif90 --showme:link)
# mpich
FMPIFLAGS += $(wordlist 2, 999, $(shell $(FC) -link_info))
# Intel MPI
# FMPIFLAGS += $(wordlist 2, 999, $(shell mpiifort -show))
# CLDFLAGS += -nofor_main

FFLAGS = -g -Og -ILibPFASST/include
FFLAGS += -fcheck=all -fbacktrace -ffpe-trap=invalid,zero,overflow -fbounds-check -fimplicit-none -ffree-line-length-none
FLDFLAGS += -LLibPFASST/lib -lpfasst

OBJ  = $(addprefix $(BUILDDIR)/,$(FSRC:.f90=.o) $(CSRC:.c=.o))

print-%  : ; @echo $* = $($*)

all: $(BUILDDIR)/cmain $(BUILDDIR)/fmain

$(BUILDDIR)/%.o: $(SRCDIR)/%.c
	@mkdir -p $(BUILDDIR)
	$(CC) -c -o $@ $< $(CFLAGS)

$(BUILDDIR)/%.o: $(SRCDIR)/%.f90
	@mkdir -p $(BUILDDIR)
	$(FC) -c -o $@ -J$(BUILDDIR) $< $(FFLAGS)

$(BUILDDIR)/cmain: $(BUILDDIR)/cmain.o $(OBJ)
	$(CC) -o $@ $^ $(CLDFLAGS) $(FMPIFLAGS)

$(BUILDDIR)/fmain: $(BUILDDIR)/fmain.o $(OBJ)
	$(FC) -o $@ $^ $(FLDFLAGS)

$(OBJ): libpfasst

libpfasst:
	cd LibPFASST; $(MAKE) DEBUG=TRUE

clean:
	\rm -rf build
	cd LibPFASST; $(MAKE) clean