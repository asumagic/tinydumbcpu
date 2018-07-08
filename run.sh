#!/bin/bash

set -e

if (( $# != 1 )); then
	echo "Bad number of parameters! Expected 1, got $#."
	echo "Syntax: ./run.sh source.bf"
	exit 1
fi

./verilator_build.sh
./bfcompiler_build.sh

cd build

echo "=> Compiling source"
./bfc $1 > pmem_bytecode.txt

echo "=> Running simulator"
./obj_dir/Vcpu