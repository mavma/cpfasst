#!/bin/bash

# Usage: build EX2 in the LibPFASST examples, then invoke from project root with the nml file path, e.g.
# ./tests/ex2_compare.sh probin.nml

IGNORE_REGEXP="(^\s*(date|time|mpibuflen):(.*|$)|^.*\.nml(.*|$))"

DIFF=$(diff -u -B -a <(grep -vE "$IGNORE_REGEXP" <(./cmain "$1"))  <(grep -vE "$IGNORE_REGEXP" <(./LibPFASST/Tutorials/EX2_Dahlquist/main.exe "$1")))

if [[ $DIFF ]]; then
  echo "$DIFF"
  exit 1
else
  exit 0
fi


