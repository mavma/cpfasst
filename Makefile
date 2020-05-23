MPICH_BIN = /opt/mpich/bin

CSRC = sweeper.c encap.c hooks.c level.c cmain.c
FSRC = cpf_encap.f90 cpf_imex_sweeper.f90 cpf_level.f90 hooks.f90 cpf_interface.f90
BUILDDIR = build
SRCDIR = src

CC = $(MPICH_BIN)/mpicc
CFLAGS = -g -O0 -I.
CLDFLAGS += -LLibPFASST/lib -lpfasst
CLDFLAGS += -lgfortran -lquadmath -lm -ldl

FC = $(MPICH_BIN)/mpif90
FFLAGS = -g -O0 -ILibPFASST/include -cpp
FFLAGS += -fcheck=all -fbacktrace -ffpe-trap=invalid,zero,overflow -fbounds-check -fimplicit-none -ffree-line-length-none
FLDFLAGS += -LLibPFASST/lib -lpfasst

# Uncomment next line for OpenMPI
# FMPIFLAGS += $(shell mpif90 --showme:link)
# Uncomment next line for mpich
FMPIFLAGS += $(wordlist 2, 999, $(shell $(FC) -link_info))
# Uncomment next 2 lines for Intel MPI
# FMPIFLAGS += $(wordlist 2, 999, $(shell $(FC) -show))
# CLDFLAGS += -nofor_main

OBJ  = $(addprefix $(BUILDDIR)/,$(FSRC:.f90=.o) $(CSRC:.c=.o))

cmain: $(OBJ)
	$(CC) -o $@ $^ $(CLDFLAGS) $(FMPIFLAGS)

$(BUILDDIR)/%.o: $(SRCDIR)/%.c
	@mkdir -p $(BUILDDIR)
	$(CC) -c -o $@ $< $(CFLAGS)

$(BUILDDIR)/%.o: $(SRCDIR)/%.f90
	@mkdir -p $(BUILDDIR)
	$(FC) -c -o $@ -J$(BUILDDIR) $< $(FFLAGS)

$(OBJ): libpfasst

libpfasst:
	cd LibPFASST; $(MAKE) DEBUG=TRUE MKVERBOSE=TRUE FC=$(FC) CC=$(CC)

libpfasst_examples: libpfasst
	cd LibPFASST/Tutorials/EX1_Dahlquist; $(MAKE) DEBUG=TRUE MKVERBOSE=TRUE FC=$(FC) CC=$(CC)
	cd LibPFASST/Tutorials/EX2_Dahlquist; $(MAKE) DEBUG=TRUE MKVERBOSE=TRUE FC=$(FC) CC=$(CC)
	cd LibPFASST/Tutorials/EX3_adv_diff; $(MAKE) DEBUG=TRUE MKVERBOSE=TRUE FC=$(FC) CC=$(CC)
	# cd LibPFASST/Tutorials/EX4_Boussinesq; $(MAKE) DEBUG=TRUE MKVERBOSE=TRUE FC=$(FC) CC=$(CC)

all: cmain libpfasst_examples

clean:
	\rm -rf cmain
	\rm -rf build

clean_all: clean
	cd LibPFASST; $(MAKE) clean
	cd LibPFASST/Tutorials/EX1_Dahlquist; $(MAKE) clean
	cd LibPFASST/Tutorials/EX2_Dahlquist; $(MAKE) clean
	cd LibPFASST/Tutorials/EX3_adv_diff; $(MAKE) clean
	# cd LibPFASST/Tutorials/EX4_Boussinesq; $(MAKE) clean