#!/bin/bash

# Usage: build EX2 in the LibPFASST and cpfasst examples, then invoke from project root

PATH_CPF=examples/EX2_Dahlquist/
PATH_LPF=LibPFASST/Tutorials/EX2_Dahlquist/

CPF_TO_LPF=$(realpath --relative-to=$PATH_CPF $PATH_LPF)

for nml in "probin" "sdc" "multi_level" "pipeline"; do
  echo "Testing EX2 with nml file $nml"
  [ ! -e $PATH_CPF/dat ] || rm -r $PATH_CPF/dat
  [ ! -e $PATH_LPF/dat ] || rm -r $PATH_LPF/dat
  (cd $PATH_CPF && ./main "$CPF_TO_LPF/$nml.nml") > /dev/null
  (cd $PATH_LPF && ./main.exe "$nml.nml") > /dev/null
  ./tests/compare.py $PATH_CPF/dat/outdirP0001 $PATH_LPF/dat/outdirP0001
  echo ""
done