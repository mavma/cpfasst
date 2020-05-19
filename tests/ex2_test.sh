#!/bin/bash

# Usage: build EX2 in the LibPFASST examples, then invoke from project root

for nml in "probin" "sdc" "multi_level" "pipeline"; do
  echo "Testing EX2 with nml file $nml"
  # rm -r dat/*
  ./cmain "$nml.nml" > /dev/null # cpfasst-$nml.out
  # rm -r LibPFASST/Tutorials/EX2_Dahlquist/dat/*
  (cd LibPFASST/Tutorials/EX2_Dahlquist && ./main.exe "$nml.nml") > /dev/null # libpfasst-$nml.out
  ./tests/compare.py dat/outdirP0001 LibPFASST/Tutorials/EX2_Dahlquist/dat/outdirP0001
  echo ""
done