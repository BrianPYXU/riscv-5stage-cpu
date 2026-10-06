# Day 10 — EX/MEM Pipeline Register

## Completed

- Implemented the EX/MEM pipeline register.
- Stored ALU results and store data for the MEM stage.
- Added control signals for memory access and register write-back.
- Added synchronous reset support.
- Added stall support to hold the current values.
- Added flush support to clear the pipeline register.
- Verified control priority:
  - reset
  - flush
  - stall
  - normal update

## Stored Signals

- `alu_result`
- `store_data`
- `rd`
- `reg_write`
- `mem_read`
- `mem_write`

## Key Concepts

- The EX/MEM register transfers results from the EX stage to the MEM stage.
- `alu_result` can be used as an ALU result or memory address.
- `store_data` carries the data that may be written to memory.
- `reg_write`, `mem_read`, and `mem_write` are 1-bit control signals.
- `stall = 1` keeps the current values.
- `flush = 1` clears the register.
- The register updates on `posedge clk`.

## Verification

Verified with GTKWave:

- Reset clears all outputs.
- Normal inputs are captured on the next positive clock edge.
- Stall holds the previous values.
- Flush clears all outputs.
- Flush has higher priority than stall.
- Normal updating resumes after stall is removed.