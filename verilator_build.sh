#!/bin/bash

mkdir build &> /dev/null
cd build

echo "=> Running verilator"
verilator -Wall -I../rtl/ -cc ../rtl/cpu.sv --top-module cpu --exe ../../tb/verilator/sim_main.cpp

cd obj_dir

echo "=> Building verilator sources"
make OPT_FAST="-Os" -f ./Vcpu.mk Vcpu -j4

cd ../../