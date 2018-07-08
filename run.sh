#!/bin/bash

./verilator_build.sh
./bfcompiler_build.sh

cd build

./bfc $1 > pmem_bytecode.txt
./obj_dir/Vcpu