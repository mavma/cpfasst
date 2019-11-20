FSRC = probin.f90 level.f90 sweeper.f90 interface.f90
CSRC = cmain.c

CC = mpicc
FC = mpif90
# CC = gcc
# FC = gfortran
CFLAGS=-g -Og -I.
FFLAGS=-g -Og -ILibPFASST/include

OBJ += $(FSRC:.f90=.o)
OBJ += $(CSRC:.c=.o)

LDFLAGS += -LLibPFASST/lib -lpfasst
LDFLAGS += -lgfortran -lquadmath 
LDFLAGS += $(shell mpif90 --showme:link)

all: libpfasst cflink

%.o: %.c
	$(CC) -c -o $@ $< $(CFLAGS)

%.o: %.f90
	$(FC) -c -w $< $(FFLAGS)

cflink: $(OBJ)
	$(CC) -o $@ $^ $(LDFLAGS)

libpfasst:
	cd LibPFASST; $(MAKE)

clean:
	\rm -f *.o *.mod cflink