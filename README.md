## TinyDumbCPU

This is a multiple cycle CPU which is meant to execute (almost) unmodified Brainf\*ck source code.

Bear in mind, this is a messy learning SystemVerilog project. Review greatly appreciated.

### Usage

#### Simulation

You need:

- [Verilator](https://www.veripool.org/wiki/verilator)
- python3
- A C++17 compiler (for the Verilator simulation)

For \*nix, use `./run.sh /path/to/a/brainfsck/source.b`.  
This will compile the design using Verilator, map your source file and execute it.

### Status

- Can run mandelbrot compiled through bfcompiler and tested with Verilator.
- Implemented for the [C5G board](http://c5g.terasic.com/) (Cyclone V GX Starter Kit).
- Character input unimplemented.

### Instruction set

The instruction set is identical to that of Brainf\*ck. However, the source has to be preprocessed and mapped by [bfcompiler](bfcompiler/compiler.py) into a file [that can be read by `$readmemb`](rtl/rom_pmem.sv).

## Gallery

Executing the famous mandelbrot program on the C5G board:

![mandel.b under TDCPU, C5G](https://i.imgur.com/UnkMOtT.png)