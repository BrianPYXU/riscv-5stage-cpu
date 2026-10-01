# Day 7 — 5-Stage Pipeline Overview

## Learned

- IF: Instruction Fetch
- ID: Instruction Decode and Register Read
- EX: ALU Execution
- MEM: Data Memory Access
- WB: Register Write Back

## Pipeline Registers

- IF/ID
- ID/EX
- EX/MEM
- MEM/WB

Pipeline registers store stage outputs at the clock edge and pass them to the next stage.

## Key Idea

Pipeline execution allows multiple instructions to be active at the same time in different stages.

## Hazards

- Data Hazard
- Control Hazard
- Structural Hazard

Future work will add forwarding, stalls, and branch handling.