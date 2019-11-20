CSRC = 
FSRC = probin.f90 level.f90 sweeper.f90 interface.f90

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

all: libpfasst cmain fmain

%.o: %.c
	$(CC) -c -o $@ $< $(CFLAGS)

%.o: %.f90
	$(FC) -c -w $< $(FFLAGS)

cmain: cmain.o $(OBJ)
	$(CC) -o $@ $^ $(LDFLAGS)

fmain: fmain.o $(OBJ)
	$(CC) -o $@ $^ $(LDFLAGS)

libpfasst:
	cd LibPFASST; $(MAKE) DEBUG=TRUE

clean:
	\rm -f *.o *.mod cflink
	cd LibPFASST; $(MAKE) clean