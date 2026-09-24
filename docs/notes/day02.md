# Day 2 — RISC-V Register File

## Completed

- Implemented a 32 × 32-bit register file.
- Two combinational read ports.
- One clocked write port.
- Added `write_enable` control.
- Protected RISC-V `x0` from writes.
- Verified the design using Icarus Verilog and GTKWave.

## Key Concepts

- Register address: 5 bits (`x0`–`x31`)
- Register data: 32 bits
- Read → combinational
- Write → `posedge clk`
- `x0` always reads as `0`

## Verification

Tested:
- `x5 = 50`
- `x7 = 100`
- Simultaneous reads
- Write disabled with `write_enable = 0`
- Attempted write to `x0`