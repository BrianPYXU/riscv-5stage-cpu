# Day 3 — Program Counter

## Completed

- Implemented a 32-bit Program Counter.
- PC increments by 4 on each clock cycle.
- Added synchronous reset.
- Verified the design using Icarus Verilog and GTKWave.

## Key Concepts

- PC stores the address of the current instruction.
- RV32I instructions are 4 bytes, so the normal next PC is `PC + 4`.
- PC updates on the positive clock edge.
- Synchronous reset takes effect on a clock edge.

## Verification

- Reset → PC = 0
- Normal operation → 0, 4, 8, 12...
- Reset asserted between clock edges → PC resets at the next positive edge.