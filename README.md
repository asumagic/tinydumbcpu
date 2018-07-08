## TinyDumbCPU

First verilog project. Disregard the git history mess, my goal is far from doing an actually usable CPU ;)

This is a multiple cycle CPU.

![mandel.b under TDCPU, C5G](https://i.imgur.com/UnkMOtT.png)

### Status

- Can run mandelbrot compiled through bfcompiler in Icarus Verilog.
- Implemented for the [C5G board](http://c5g.terasic.com/) (Cyclone V GX Starter Kit).
- Character input unimplemented.

### Instruction set

The instruction set is identical to that of Brainf\*ck, but with different opcode for values, i.e. characters are mapped to the following bits by [bfcompiler](bfcompiler/main.cpp).

- `+` -> `000`
- `-` -> `001`
- `>` -> `010`
- `<` -> `011`
- `[` -> `100`
- `]` -> `101`
- `.` -> `110`
- `,` -> `111`
