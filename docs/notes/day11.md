# Day 11 — MEM/WB Pipeline Register

## Completed

- Implemented the MEM/WB pipeline register.
- Stored ALU results, memory data, destination register, and write-back control signals.
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
- `memory_data`
- `rd`
- `reg_write`
- `mem_to_reg`

## Key Concepts

- The MEM/WB register transfers data from the MEM stage to the WB stage.
- `mem_to_reg` selects whether write-back data comes from the ALU result or memory.
- `reg_write` controls whether the destination register is updated.
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