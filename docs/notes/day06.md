# Day 6 — Datapath Integration

## Completed

- Integrated the Instruction Decoder, Register File, ALU, Immediate Generator, and MUX.
- Added ALU source selection between register data and immediate data.
- Added support for R-type ADD/SUB and I-type ADDI.
- Verified register write-back on the positive clock edge.
- Verified that later instructions can use results written by earlier instructions.

## Key Concepts

- `alu_src = 0` selects `read_data2`.
- `alu_src = 1` selects `immediate`.
- ALU results are combinational.
- Register File writes occur on `posedge clk`.
- The ALU result is connected to the Register File `write_data`.

## Verification

Tested:

- `add x5, x2, x3`
  - x2 = 10, x3 = 20
  - x5 = 30
- `sub x6, x5, x2`
  - x6 = 20
- `addi x7, x6, 5`
  - x7 = 25
- `addi x8, x7, -4`
  - x8 = 21

## Debugging

- Fixed the MUX input-selection direction so R-type instructions use `read_data2` and ADDI uses the immediate value.