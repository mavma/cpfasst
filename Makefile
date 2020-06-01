cpfasst:

build_dir = build
obj = cpf_encap.o cpf_imex_sweeper.o cpf_level.o cpf_interface.o cpf_utils.o
-include ${obj:%.o=${build_dir}/%.d}

include common.mk

cpfasst: $(build_dir)/libcpfasst.a

$(build_dir)/libcpfasst.a: $(addprefix $(build_dir)/,$(obj)) Makefile | $(build_dir)
	$(AR) $@ $(filter-out Makefile,$^)

$(build_dir):
	@mkdir $@

$(build_dir)/%.o: src/%.f90 Makefile | $(build_dir) libpfasst
	$(FC) -c -o $@ -J$(build_dir) -MD -MP $(FFLAGS) $<

$(build_dir)/%.o: src/%.c Makefile | $(build_dir) libpfasst
	$(CC) -c -o $@ -MD -MP $(CFLAGS) $<

libpfasst:
	cd LibPFASST; $(MAKE) DEBUG=TRUE MKVERBOSE=TRUE FC=$(FC) CC=$(CC)

libpfasst_examples: | libpfasst
	cd LibPFASST/Tutorials/EX1_Dahlquist; $(MAKE) DEBUG=TRUE MKVERBOSE=TRUE FC=$(FC) CC=$(CC)
	cd LibPFASST/Tutorials/EX2_Dahlquist; $(MAKE) DEBUG=TRUE MKVERBOSE=TRUE FC=$(FC) CC=$(CC)
	cd LibPFASST/Tutorials/EX3_adv_diff; $(MAKE) DEBUG=TRUE MKVERBOSE=TRUE FC=$(FC) CC=$(CC)

examples: | cpfasst libpfasst
	cd examples/EX2_Dahlquist; $(MAKE)
	cd examples/EX3_adv_diff; $(MAKE)

all: cpfasst examples libpfasst libpfasst_examples

clean:
	\rm -r build

clean_all: clean
	cd examples/EX2_Dahlquist; $(MAKE) clean
	cd examples/EX3_adv_diff; $(MAKE) clean
	cd LibPFASST; $(MAKE) clean
	cd LibPFASST/Tutorials/EX1_Dahlquist; $(MAKE) clean
	cd LibPFASST/Tutorials/EX2_Dahlquist; $(MAKE) clean
	cd LibPFASST/Tutorials/EX3_adv_diff; $(MAKE) clean

.PHONY: clean all cpfasst libpfasst libpfasst_examples clean_all examples