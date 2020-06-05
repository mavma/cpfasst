#!/bin/bash

# Convenience script for running cpfasst examples with all input files
#
# Usage: $ ./tests/run_example.sh [-bq] [-n numproc] [-i nmlfile] exname
#   -b: Also run corresponding LibPFASST tutorial
#   -n: Number of processors for parallel run (default=1)
#   -i: Run for a specific nml file e.g. 'probin' (default: run for all)
#   -q: Quiet mode
#   exname: Name of the example, e.g. 'EX2_Dahlquist'

set -ex

np=1; run_lpf=false; inputs=("probin" "sdc" "multi_level" "pipeline"); output="/dev/stdout";
while getopts ":n:i:bq" opt; do
  case $opt in
    n) np="$OPTARG"
    ;;
    b) run_lpf=true
    ;;
    i) inputs=("$OPTARG")
    ;;
    q) output="/dev/null"
    ;;
    \?) echo "Invalid option -$OPTARG" >&2
    ;;
    :)  echo "Option -$OPTARG requires an argument." >&2
    exit 1
    ;;
  esac
done
shift $((OPTIND-1))

PATH_CPF="examples/$1/"
PATH_LPF="LibPFASST/Tutorials/$1/"

CPF_TO_LPF=$(realpath --relative-to="$PATH_CPF" "$PATH_LPF")
for nml in "${inputs[@]}"; do
  echo "Running $PATH_CPF with input $nml.nml"
  (cd "$PATH_CPF" && mpiexec -n "$np" ./main "$CPF_TO_LPF/$nml.nml") > $output
  if $run_lpf ; then
    echo "Running $PATH_LPF with input  $nml.nml"
     (cd "$PATH_LPF" && mpiexec -n "$np" ./main.exe "$nml.nml") > $output
  fi
done