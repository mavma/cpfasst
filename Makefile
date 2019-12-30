SRC =
FSRC = probin.f90 level.f90 sweeper.f90 interface.f90

CC = mpicc
CFLAGS = -g -O0 -I.
CLDFLAGS += -LLibPFASST/lib -lpfasst
CLDFLAGS += -lgfortran -lquadmath

# OpenMPI
# FMPIFLAGS += $(shell mpif90 --showme:link)
# mpich
FMPIFLAGS += $(wordlist 2, 999, $(shell mpif90 -link_info))
# Intel MPI
# FMPIFLAGS += $(wordlist 2, 999, $(shell mpiifort -show))
# CLDFLAGS += -nofor_main

FC = mpifort
FFLAGS = -g -Og -ILibPFASST/include
FFLAGS += -fcheck=all -fbacktrace -ffpe-trap=invalid,zero,overflow -fbounds-check -fimplicit-none -ffree-line-length-none
FLDFLAGS += -LLibPFASST/lib -lpfasst

OBJ += $(CSRC:.c=.o)
OBJ += $(FSRC:.f90=.o)

print-%  : ; @echo $* = $($*)

all: cmain fmain

%.o: %.c
	$(CC) -c -o $@ $< $(CFLAGS)

%.o: %.f90
	$(FC) -c -w $< $(FFLAGS)

cmain: cmain.o $(OBJ)
	$(CC) -o $@ $^ $(CLDFLAGS) $(FMPIFLAGS)

fmain: fmain.o $(OBJ)
	$(FC) -o $@ $^ $(FLDFLAGS)

$(OBJ): libpfasst

libpfasst:
	cd LibPFASST; $(MAKE) DEBUG=TRUE

clean:
	\rm -f *.o *.mod cmain fmain
	cd LibPFASST; $(MAKE) clean