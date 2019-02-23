#!/bin/bash

if (( $# != 1 )); then
	echo "Bad number of parameters! Expected 1, got $#."
	echo "Syntax: ./run.sh source.bf"
	exit 1
fi

./verilator_build.sh

echo "-- Compiling bf source to bytecode"
python3 ./bfcompiler/compiler.py $1 > build/pmem_bytecode.txt

cd build

echo "-- Executing simulation"
./obj_dir/Vcpu
