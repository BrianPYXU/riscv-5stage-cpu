# Day 5 — Immediate Generator

## Completed

- Learned how immediate values are encoded in RISC-V instructions.
- Implemented I-type and S-type immediate generation.
- Implemented sign extension from 12 bits to 32 bits.
- Verified positive and negative immediate values using GTKWave.

## Key Concepts

- I-type immediate:
  - `instruction[31:20]`
- S-type immediate:
  - `{instruction[31:25], instruction[11:7]}`
- Immediate values are sign-extended to 32 bits.
- `instruction[31]` is used as the sign bit.
- The Immediate Generator is combinational logic and does not require a clock.
- Default assignments help avoid unintended latch inference.

## Verification

Tested:

- `addi x5, x2, 10` → immediate = `10`
- `addi x5, x2, -4` → immediate = `-4`
- `sw x5, 8(x2)` → immediate = `8`

## Future Work

- Add B-type immediate support for branch instructions.
- Add U-type and J-type immediate support when those instructions are implemented.