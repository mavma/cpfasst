# cpfasst

![test](https://github.com/mavma/cpfasst/workflows/test/badge.svg?branch=master)

### Run the program

#### Clone and initialize submodules
```
git clone https://github.com/mavma/cpfasst.git
git submodule update --init --recursive
```

#### Configure MPI

##### mpich
The makefile is preconfigured for use with mpich. The mpich binary path can be overridden using the variable MPICH_BIN when invoking make, e.g.
```
make MPICH_BIN=/usr/bin 
```

##### OpenMPI and Intel MPI
_Note: cpfasst is tested only with mpich. The instructions for different compilers are included for didactic purposes._

To compile with OpenMPI, the CC and FC variables must be overridden with the paths to the C and Fortran MPI compilers respectively. Additionally, uncomment the relevant lines in the Makefile to correctly set the linking flags for the chosen compiler. 
```
# Uncomment next line for OpenMPI
# FMPIFLAGS += $(shell mpif90 --showme:link)
# Uncomment next line for mpich
# FMPIFLAGS += $(wordlist 2, 999, $(shell $(FC) -link_info))
# Uncomment next 2 lines for Intel MPI
# FMPIFLAGS += $(wordlist 2, 999, $(shell $(FC) -show))
# CLDFLAGS += -nofor_main
```

#### Build project
```
make
```

#### Run example
```
./cmain
```

### Developer setup

Use commit hooks to save compiler versions used
```
git config core.hooksPath .githooks
```