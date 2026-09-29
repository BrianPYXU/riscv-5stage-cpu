# Day 4 — Instruction Decoder

## Completed

- Learned the basic RISC-V R-type and I-type instruction formats.
- Implemented instruction field extraction.
- Added basic ALU control decoding for ADD and SUB.
- Verified the decoder using Icarus Verilog and GTKWave.

## Key Concepts

- A RISC-V instruction is 32 bits.
- R-type fields:
  - `opcode`
  - `rd`
  - `funct3`
  - `rs1`
  - `rs2`
  - `funct7`
- `opcode`, `funct3`, and `funct7` are used to identify operations.
- Decoder logic is combinational and does not require a clock.
- Default assignments help avoid unintended latch inference.

## ALU Control

- `0000` → ADD
- `0001` → SUB
- `1111` → Unsupported operation

## Verification

Tested:
- `add x5, x2, x3`
- `sub x10, x6, x7`
- Correct register field extraction
- Correct ADD/SUB ALU control output