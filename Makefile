SRC =
FSRC = probin.f90 level.f90 sweeper.f90 interface.f90
BUILDDIR = build
SRCDIR = .

CC = mpicc
CFLAGS = -g -O0 -I.
CLDFLAGS += -LLibPFASST/lib -lpfasst
CLDFLAGS += -lgfortran -lquadmath

# OpenMPI
# FMPIFLAGS += $(shell mpif90 --showme:link)
# mpich
FMPIFLAGS += $(wordlist 2, 999, $(shell mpif90 -link_info))
# Intel MPI
# FMPIFLAGS += $(wordlist 2, 999, $(shell mpiifort -show))
# CLDFLAGS += -nofor_main

FC = mpifort
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