# Day 16 - Instruction Memory and PC-Based Fetch

## Goal

Replace manual testbench-driven instruction input with instruction-memory-based program fetching.

## Implemented

- Added a 256 x 32-bit instruction memory
- Added combinational instruction read
- Connected PC directly to instruction memory
- Removed the external instruction input from `pipeline_top`
- Added PC-based sequential instruction fetching
- Verified multi-instruction program execution
- Verified branch target refetch from instruction memory
- Added end-to-end branch execution test

## Instruction Memory

The instruction memory is implemented as:

```verilog
reg [31:0] memory [0:255];