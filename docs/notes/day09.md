# Day 9 — ID/EX Pipeline Register

## Completed

- Implemented the ID/EX pipeline register.
- Stored data and control signals for the EX stage.
- Added synchronous reset support.
- Added stall support to hold the current values.
- Added flush support to clear the pipeline register.
- Verified control priority:
  - reset
  - flush
  - stall
  - normal update

## Stored Signals

- `read_data1`
- `read_data2`
- `immediate`
- `rd`
- `alu_control`
- `alu_src`

## Key Concepts

- The ID/EX register passes decoded operands and control signals from the ID stage to the EX stage.
- `stall = 1` keeps the current output values.
- `flush = 1` clears the stored values.
- Pipeline registers update on `posedge clk`.

## Verification

Verified with GTKWave:

- Reset clears all outputs.
- Normal inputs are captured on the next positive clock edge.
- Stall holds the previous values.
- Flush clears all outputs.
- Flush has higher priority than stall.
- Normal updating resumes after stall is removed.