#!/bin/bash

shopt -s extglob

mkdir build &> /dev/null
cd build

echo "=> Running verilator"
verilator -Wall -I../rtl/ -cc ../rtl/cpu.sv --top-module cpu

cd obj_dir

echo "=> Building verilator sources"
make -f ./Vcpu.mk

cd ../../
