#!/bin/bash

mkdir build
cd build

g++ -Os ../bfcompiler main.cpp -Wall -Wextra -o ./bfc

cd ../