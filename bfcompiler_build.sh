#!/bin/bash

mkdir build
cd build

echo "=> Compiling source compiler"

g++ -std=c++17 -Os ../bfcompiler/main.cpp -Wall -Wextra -o ./bfc

cd ../