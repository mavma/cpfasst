FSRC = cpf_encap.f90 cpf_imex_sweeper.f90 cpf_level.f90 cpf_interface.f90
BUILDDIR = build
SRCDIR = src

CPFASST ?= $(PWD)
include $(CPFASST)/common.mk

OBJ  = $(addprefix $(BUILDDIR)/,$(FSRC:.f90=.o))

lib/libcpfasst.a: $(OBJ)
	@mkdir -p lib
	$(AR) $@ $(OBJ)

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

all: cmain libpfasst_examples

clean:
	\rm -r lib
	\rm -r build

clean_all: clean
	cd LibPFASST; $(MAKE) clean
	cd LibPFASST/Tutorials/EX1_Dahlquist; $(MAKE) clean
	cd LibPFASST/Tutorials/EX2_Dahlquist; $(MAKE) clean
	cd LibPFASST/Tutorials/EX3_adv_diff; $(MAKE) clean