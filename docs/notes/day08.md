# Day 8 — IF/ID Pipeline Register

## Completed

- Implemented the IF/ID pipeline register.
- Stored the PC and instruction on the positive clock edge.
- Added synchronous reset support.
- Added stall support to hold the current register values.
- Added flush support to clear the pipeline register.
- Verified the control priority:
  - reset
  - flush
  - stall
  - normal update

## Key Concepts

- The IF/ID register passes the PC and instruction from the IF stage to the ID stage.
- `stall = 1` keeps the current output values.
- `flush = 1` clears the pipeline register.
- Pipeline registers are sequential logic and update on `posedge clk`.

## Verification

Verified with GTKWave:

- Reset clears the outputs.
- Normal input values are captured on the next positive clock edge.
- Stall keeps the previous values.
- Flush clears the outputs.
- Flush has higher priority than stall.
- Normal updating resumes after stall and flush are removed.