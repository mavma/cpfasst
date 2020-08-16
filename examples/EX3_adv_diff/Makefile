CPFASST_DIR = ../..
include $(CPFASST_DIR)/common.mk

BUILD_DIR = build
OBJ = fft_tool.o sweeper.o encap.o level.o probin.o shared.o solution.o utils.o main.o

IFLAGS := -Ilibfftpack -I$(CPFASST_DIR)/include
LFLAGS := -Llibfftpack -lfftpack -L$(CPFASST_DIR)/build -lcpfasst

main: $(addprefix $(BUILD_DIR)/,$(OBJ)) Makefile $(CPFASST_DIR)/build/libcpfasst.a | $(BUILD_DIR) cpfasst libfftpack
	$(LDv) -o $@ $(filter-out Makefile,$^) $(LFLAGS) $(LDFLAGS) $(FMPIFLAGS)

$(BUILD_DIR):
	@mkdir $@

$(BUILD_DIR)/%.o: src/%.c Makefile | $(BUILD_DIR) cpfasst libfftpack
	$(CCv) -c -o $@ -MD -MP $(CFLAGS) $(IFLAGS) $<

-include ${OBJ:%.o=${BUILD_DIR}/%.d}

Makefile: $(CPFASST_DIR)/common.mk
	@touch Makefile

.PHONY: libfftpack
libfftpack:
	@cd libfftpack; $(MAKE)

.PHONY: cpfasst
cpfasst:
	@cd $(CPFASST_DIR); $(MAKE)

.PHONY: all
all: main

.PHONY: clean
clean:
	\rm -f main
	\rm -rf build