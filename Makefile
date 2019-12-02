CSRC = 
FSRC = probin.f90 level.f90 sweeper.f90 interface.f90

CC = mpiicc
CFLAGS = -g -O0 -I.
CLDFLAGS += -LLibPFASST/lib -lpfasst
CLDFLAGS += -lgfortran -lquadmath

# OpenMPI
# CLDFLAGS += $(shell mpif90 --showme:link)

# mpich
# CLDFLAGS += $(wordlist 2, 999, $(shell mpif90 -link_info))

# Intel MPI
CLDFLAGS += $(wordlist 2, 999, $(shell mpiifort -show))

FC = mpiifort
FFLAGS = -g -Og -ILibPFASST/include
# FFLAGS += -fcheck=all -fbacktrace -ffpe-trap=invalid,zero,overflow -fbounds-check -fimplicit-none -ffree-line-length-none

# FLDFLAGS += -LLibPFASST/lib -lpfasst
# FLDFLAGS += $(shell mpicc --showme:link)

OBJ += $(CSRC:.c=.o)
OBJ += $(FSRC:.f90=.o)

print-%  : ; @echo $* = $($*)

all: cmain fmain

%.o: %.c
	$(CC) -c -o $@ $< $(CFLAGS)

%.o: %.f90
	$(FC) -c -w $< $(FFLAGS)

cmain: cmain.o $(OBJ)
	$(CC) -o $@ $^ $(CLDFLAGS)

fmain: fmain.o $(OBJ)
	$(CC) -o $@ $^ $(CLDFLAGS)

$(OBJ): libpfasst

libpfasst:
	cd LibPFASST; $(MAKE) DEBUG=TRUE

clean:
	\rm -f *.o *.mod cmain fmain
	cd LibPFASST; $(MAKE) clean