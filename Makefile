CSRC = 
FSRC = probin.f90 level.f90 sweeper.f90 interface.f90

CC = mpicc
CFLAGS = -g -Og -I.
CLDFLAGS += -LLibPFASST/lib -lpfasst
CLDFLAGS += -lgfortran -lquadmath 
# CLDFLAGS += $(shell mpif90 --showme:link) # OpenMPI
FLINK = $(shell mpif90 -link_info) # mpich
CLDFLAGS += $(FLINK:gfortran=)

FC = mpifort
FFLAGS = -g -Og -ILibPFASST/include
FFLAGS += -fcheck=all -fbacktrace -ffpe-trap=invalid,zero,overflow -fbounds-check -fimplicit-none -ffree-line-length-none
# FLDFLAGS += -LLibPFASST/lib -lpfasst
# FLDFLAGS += $(shell mpicc --showme:link)

OBJ += $(CSRC:.c=.o)
OBJ += $(FSRC:.f90=.o)

all: cmain fmain

%.o: %.c
	$(CC) -c -o $@ $< $(CFLAGS)

%.o: %.f90
	$(FC) -c -w $< $(FFLAGS)

cmain: cmain.o $(OBJ)
	$(CC) -o $@ $^ $(CLDFLAGS:f95=)
	#$(CC) -o $@ $^ $(CLDFLAGS)

fmain: fmain.o $(OBJ)
	$(CC) -o $@ $^ $(CLDFLAGS:f95=)
	#$(CC) -o $@ $^ $(CLDFLAGS)

$(OBJ): libpfasst

libpfasst:
	cd LibPFASST; $(MAKE) DEBUG=TRUE

clean:
	\rm -f *.o *.mod cmain fmain
	cd LibPFASST; $(MAKE) clean
