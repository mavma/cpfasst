# cpfasst

![test](https://github.com/mavma/cpfasst/workflows/cpfasst_test/badge.svg?branch=master)

### Run the program

#### Clone and initialize submodules
```
git clone https://github.com/mavma/cpfasst.git
git submodule update --init --recursive
```

#### Build library
Build configurations of interest to the user are located in file `common.mk`
```
make
```

#### Examples
Folder `examples` contains cpfasst applications mirrorring two of the LibPFASST tutorials. To build them, use:
```
make examples
```
or invoke `make` directly from the desired example folder. To run the examples, use:
```
./main path_to_nml_file
```
Suitable nml files for running examples are found in the corresponding LibPFASST tutorial folders. Alternatively, script `tests/test_example.py` runs a cpfasst example and the corresponding LibPFASST tutorial for all nml files, and compares their outputs.
