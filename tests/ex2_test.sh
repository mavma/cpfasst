#!/bin/bash

# Usage: build EX2 in the LibPFASST and cpfasst examples, then invoke from project root

EXAMPLE="EX2_Dahlquist"
RUN="./tests/run_example.sh"
PATH_CPF="examples/$EXAMPLE"
PATH_LPF="LibPFASST/Tutorials/$EXAMPLE"

for nml in "probin" "sdc" "multi_level" "pipeline"; do
  echo "Testing EX2 with nml file $nml"
  [ ! -e "$PATH_CPF/dat" ] || rm -r "$PATH_CPF/dat"
  [ ! -e "$PATH_LPF/dat" ] || rm -r "$PATH_LPF/dat"
  $RUN -bq -i $nml $EXAMPLE
  ./tests/compare.py "$PATH_CPF/dat/outdirP0001" "$PATH_LPF/dat/outdirP0001"
  echo ""
done