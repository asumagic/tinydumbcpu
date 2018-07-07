## TinyDumbCPU

First verilog project. Disregard the git history mess, my goal is far from doing an actually usable CPU ;)

### Instruction set

- `inc      *(sp++)`
- `dec      *(sp--)`
- `incsp      sp++`
- `decsp      sp--`
- `reljmpz  if (*sp == 0) { pc = arg_dword() }`
- `reljmpnz if (*sp != 0) { pc = arg_dword() }`
- `cin      *sp = read_from_stdin()`
- `cout     write_to_stdout(*sp)`