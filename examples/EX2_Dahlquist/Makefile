CPFASST_DIR = ../..
include $(CPFASST_DIR)/common.mk

BUILD_DIR = build
#OBJ = sweeper.o encap.o hooks.o level.o probin.o main.o
OBJ = probin.o main.o

IFLAGS := -I$(CPFASST_DIR)/include
LFLAGS := -L$(CPFASST_DIR)/build -lcpfasst

main: $(addprefix $(BUILD_DIR)/,$(OBJ)) Makefile $(CPFASST_DIR)/build/libcpfasst.a | $(BUILD_DIR) cpfasst
	$(LDv) -o $@ $(filter-out Makefile,$^) $(LFLAGS) $(LDFLAGS) $(FMPIFLAGS)

$(BUILD_DIR):
	@mkdir $@

$(BUILD_DIR)/%.o: src/%.c Makefile | $(BUILD_DIR) cpfasst
	$(CCv) -c -o $@ -MD -MP $(CFLAGS) $(IFLAGS) $<

-include ${OBJ:%.o=${BUILD_DIR}/%.d}

Makefile: $(CPFASST_DIR)/common.mk
	@touch Makefile

.PHONY: cpfasst
cpfasst:
	@cd $(CPFASST_DIR); $(MAKE)

.PHONY: all
all: main

.PHONY: clean
clean:
	\rm -f main
	\rm -rf build