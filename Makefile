include common.mk

build_dir = build
obj = cpf_utils.o cpf_encap.o cpf_imex_sweeper.o cpf_level.o cpf_parameters.o cpf_main.o cpf_interface.o

cpfasst: $(build_dir)/libcpfasst.a

$(build_dir)/libcpfasst.a: $(addprefix $(build_dir)/,$(obj)) Makefile | $(build_dir) libpfasst
	$(ARv) $@ $(filter-out Makefile,$^)

$(build_dir):
	@mkdir $@

$(build_dir)/%.o: src/%.f90 Makefile | $(build_dir) libpfasst
	$(FCv) -c -o $@ -J$(build_dir) -MD -MP $(FFLAGS) $<

$(build_dir)/%.o: src/%.c Makefile | $(build_dir) libpfasst
	$(CCv) -c -o $@ -MD -MP $(CFLAGS) $<

-include ${obj:%.o=${build_dir}/%.d}

Makefile: common.mk
	@touch Makefile

.PHONY: libpfasst
libpfasst:
	@cd LibPFASST; $(MAKE) DEBUG=TRUE MKVERBOSE=TRUE FC=$(FC) CC=$(CC) GCC10=$(GCC10)

.PHONY: libpfasst_examples
libpfasst_examples: | libpfasst
	@cd LibPFASST/Tutorials/EX1_Dahlquist; $(MAKE) DEBUG=TRUE MKVERBOSE=TRUE FC=$(FC) CC=$(CC)
	@cd LibPFASST/Tutorials/EX2_Dahlquist; $(MAKE) DEBUG=TRUE MKVERBOSE=TRUE FC=$(FC) CC=$(CC)
	@cd LibPFASST/Tutorials/EX3_adv_diff; $(MAKE) DEBUG=TRUE MKVERBOSE=TRUE FC=$(FC) CC=$(CC)

.PHONY: examples
examples: | cpfasst libpfasst
	@cd examples/EX2_Dahlquist; $(MAKE)
	@cd examples/EX3_adv_diff; $(MAKE)

.PHONY: clean
clean:
	\rm -rf build

.PHONY: clean_all
clean_all: clean
	cd examples/EX2_Dahlquist; $(MAKE) clean
	cd examples/EX3_adv_diff; $(MAKE) clean
	cd LibPFASST; $(MAKE) clean
	cd LibPFASST/Tutorials/EX1_Dahlquist; $(MAKE) clean
	cd LibPFASST/Tutorials/EX2_Dahlquist; $(MAKE) clean
	cd LibPFASST/Tutorials/EX3_adv_diff; $(MAKE) clean

.PHONY: all
all: cpfasst examples libpfasst libpfasst_examples

