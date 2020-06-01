cpfasst_dir ?= ../..
libpfasst_dir ?= $(cpfasst_dir)/LibPFASST
include $(cpfasst_dir)/common.mk

main:

build_dir = build
obj = fft_tool.o sweeper.o encap.o hooks.o level.o probin.o shared.o solution.o main.o
-include ${obj:%.o=${build_dir}/%.d}

ccflags.local = -Ilibfftpack
ldflags.local = -Llibfftpack -lfftpack

main: $(addprefix $(build_dir)/,$(obj)) Makefile | $(build_dir)
	$(CC) -o $@ $(filter-out Makefile,$^) $(ldflags.local) $(CLDFLAGS) $(FMPIFLAGS)

$(build_dir):
	@mkdir $@

$(build_dir)/%.o: src/%.c Makefile | $(build_dir) cpfasst libfftpack
	$(CC) -c -o $@ -MD -MP $(CFLAGS) $(ccflags.local) $<

cpfasst:
	cd ../..; $(MAKE)

libfftpack:
	cd libfftpack; $(MAKE)

all: main

clean:
	\rm -f main
	\rm -rf build

.PHONY: clean all cpfasst libfftpack