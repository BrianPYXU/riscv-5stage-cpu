## Day 12 – Basic 5-Stage Pipeline Integration

### What I implemented
- Integrated the main 5-stage datapath:
  IF → ID → EX → MEM → WB
- Connected the existing pipeline registers:
  IF/ID, ID/EX, EX/MEM, MEM/WB
- Extended control-signal propagation across pipeline stages
- Added the write-back MUX using `mem_to_reg`
- Used a temporary memory-data placeholder because data memory has not been implemented yet

### Verification
Tested three independent instructions to avoid data hazards:

```assembly
addi x2, x1, 8
add  x3, x4, x5
sub  x6, x7, x8