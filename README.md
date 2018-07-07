## TinyDumbCPU

First verilog project. Disregard the git history mess, my goal is far from doing an actually usable CPU ;)

### Status

- Untested on hardware (fpga)
- Not verified
- Bf -> TDCPU compiler in progress

### Instruction set

Branching is currently implemented differently, disregard the following ISA for `reljmpz` and `reljmpnz`.

- `inc      *(sp++)`
- `dec      *(sp--)`
- `incsp      sp++`
- `decsp      sp--`
- `reljmpz  if (*sp == 0) { pc = arg_dword() }`
- `reljmpnz if (*sp != 0) { pc = arg_dword() }`
- `cin      *sp = read_from_stdin()`
- `cout     write_to_stdout(*sp)`