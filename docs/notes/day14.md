# Day 14 - Data Memory, LW/SW, and Load-Use Hazard

## Goal

Integrate data memory into the 5-stage pipeline, complete basic LW/SW execution, and add load-use hazard detection.

## Implemented

- Added a 256 x 32-bit data memory.
- Added synchronous memory write.
- Added combinational memory read.
- Added LW decode control.
- Added SW decode control.
- Extended the immediate generator for LW.
- Integrated data memory into the MEM stage.
- Connected memory read data into MEM/WB.
- Added a hazard detection unit.
- Added PC stall support.
- Added IF/ID stall support.
- Added ID/EX bubble insertion for load-use hazards.

## Data Memory

The data memory is implemented as:

```verilog
reg [31:0] memory [0:255];
```