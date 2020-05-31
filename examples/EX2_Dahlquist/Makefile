cpfasst_dir ?= ../..
libpfasst_dir ?= $(cpfasst_dir)/LibPFASST
include $(cpfasst_dir)/common.mk

main:

build_dir = build
obj = sweeper.o encap.o hooks.o level.o probin.o main.o
-include ${obj:%.o=${build_dir}/%.d}

main: $(addprefix $(build_dir)/,$(obj)) Makefile | $(build_dir)
	$(CC) -o $@ $(filter-out Makefile,$^) $(CLDFLAGS) $(FMPIFLAGS)

$(build_dir):
	@mkdir $@

$(build_dir)/%.o: src/%.c Makefile | $(build_dir) cpfasst
	$(CC) -c -o $@ -MD -MP $(CFLAGS) $<

cpfasst:
	cd ../..; $(MAKE)

all: main

clean:
	\rm -f main
	\rm -rf build

.PHONY: clean all cpfasst