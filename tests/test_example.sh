#!/bin/bash

# Convenience script for testing that output of cpfasst example matches equivalent LibPFASST tutorial
#
# Usage: $ ./tests/test_example.sh exname
#   exname: Name of the example, e.g. 'EX2_Dahlquist'
#   Requires the example to be built in cpfasst and LibPFASST
#   Assumes example output folder = dat/outdirP0001

set -e

EXAMPLE=$1
RUN="./tests/run_example.sh"
PATH_CPF="examples/$EXAMPLE"
PATH_LPF="LibPFASST/Tutorials/$EXAMPLE"

for nml in "probin" "sdc" "multi_level" "pipeline"; do
  echo "Testing $EXAMPLE with nml file $nml"
  [ ! -e "$PATH_CPF/dat" ] || rm -r "$PATH_CPF/dat"
  [ ! -e "$PATH_LPF/dat" ] || rm -r "$PATH_LPF/dat"
  $RUN -bq -i $nml "$EXAMPLE"
  ./tests/compare.py "$PATH_CPF/dat/outdirP0001" "$PATH_LPF/dat/outdirP0001"
  echo ""
done