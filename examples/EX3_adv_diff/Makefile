SRC = fftpack.c sweeper.c encap.c hooks.c level.c probin.c main.c
BUILDDIR = build
SRCDIR = src

CPFASST ?= ../..
LIBPFASST ?= $(CPFASST)/LibPFASST

include $(CPFASST)/common.mk

CFLAGS += -Ilibfftpack
CLDFLAGS += -Llibfftpack -lfftpack

OBJ  = $(addprefix $(BUILDDIR)/,$(SRC:.c=.o))

main: $(OBJ)
	$(CC) -o $@ $^ $(CLDFLAGS) $(FMPIFLAGS)

$(BUILDDIR)/%.o: $(SRCDIR)/%.c
	@mkdir -p $(BUILDDIR)
	$(CC) -c -o $@ $< $(CFLAGS)

$(OBJ) : cpfasst

cpfasst:
	cd ../..; $(MAKE)

clean:
	\rm main
	\rm -r build