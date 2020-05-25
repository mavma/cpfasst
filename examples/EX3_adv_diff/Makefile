SRC = fftpack.c main.c
BUILDDIR = build
SRCDIR = src

CPFASST ?= ../..
LIBPFASST ?= $(CPFASST)/LibPFASST

include $(CPFASST)/common.mk

CFLAGS += -Ilibfftpack
CLDFLAGS += -Llibfftpack -lfftpack

OBJ  = $(addprefix $(BUILDDIR)/,$(SRC:.c=.o))

main: $(OBJ) $(CPFASST)/lib/libcpfasst.a
	$(CC) -o $@ $^ $(CLDFLAGS) $(FMPIFLAGS)

$(BUILDDIR)/%.o: $(SRCDIR)/%.c
	@mkdir -p $(BUILDDIR)
	$(CC) -c -o $@ $< $(CFLAGS)

clean:
	\rm main
	\rm -r build