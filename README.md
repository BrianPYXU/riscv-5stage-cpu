# 5-Stage Pipelined RISC-V CPU (Work in Progress)

A work-in-progress 32-bit RISC-V processor implemented in Verilog and verified with Icarus Verilog and GTKWave. The current implementation includes a basic pre-pipeline datapath supporting ADD, SUB, and ADDI, together with four standalone pipeline registers intended for a 5-stage IF/ID/EX/MEM/WB architecture.

The full 5-stage CPU is not yet integrated. Instruction and data memory, the complete write-back path, forwarding, automatic hazard detection, load-use stalls, branch handling, broader RV32I support, and end-to-end program execution remain in progress.

## Current Progress

Completed items below refer either to standalone RTL modules or the basic pre-pipeline datapath. The pipeline-register `stall` and `flush` inputs are implemented and individually tested, but CPU-wide hazard detection and automatic stall/flush control are not yet implemented.

### RTL Components

- [x] 32-bit Register
- [x] 32-bit 2-to-1 Multiplexer
- [x] Basic 32-bit ALU
- [x] Register File
- [x] Program Counter (standalone module)
- [x] Instruction Decoder (ADD, SUB, ADDI)
- [x] Immediate Generator (ADDI I-type and store S-type immediates)

### Basic Pre-Pipeline Datapath

- [x] Basic Datapath Integration (ADD, SUB, ADDI)
- [x] Register-file read, ALU operand selection, ALU execution, and register-file write-back exercised in simulation

### Pipeline Registers

- [x] IF/ID Pipeline Register
- [x] ID/EX Pipeline Register
- [x] EX/MEM Pipeline Register
- [x] MEM/WB Pipeline Register

Each pipeline register has been tested independently for reset, normal update, stall, and flush behavior.

### Full CPU Integration

- [ ] Initial 5-stage pipeline integration
- [ ] Instruction Memory / Fetch Integration
- [ ] Data Memory / Load-Store Integration
- [ ] Complete pipelined write-back path and control-signal propagation
- [ ] Data Forwarding
- [ ] Hazard Detection / Stall
- [ ] Load-Use Stall Handling
- [ ] Branch Handling / Pipeline Flush
- [ ] Broader RV32I instruction support
- [ ] End-to-end program-based CPU verification

## Current Instruction Support

The current **pre-pipeline datapath** supports:

| Instruction | Status |
| --- | --- |
| ADD | Implemented |
| SUB | Implemented |
| ADDI | Implemented |

These instructions are currently exercised in the basic datapath rather than in a fully integrated pipelined CPU.

The immediate generator also implements S-type immediate extraction for store instructions. This does **not** mean that store execution is currently supported; data memory and the complete load/store datapath have not yet been integrated.

## Verification Status

Current verification uses dedicated Verilog testbenches, Icarus Verilog simulation, and GTKWave waveform inspection.

The existing tests cover individual RTL modules, all four pipeline registers, and the basic ADD/SUB/ADDI datapath. The current datapath testbench supplies instructions directly and initializes selected register-file entries from the testbench, which is appropriate for component and datapath development but is not intended to be the final CPU verification method.

Planned final verification will add self-checking testbenches with automatic expected-result comparisons and explicit PASS/FAIL reporting. End-to-end tests will execute instruction sequences through instruction memory and verify the resulting architectural register and memory state, including forwarding, RAW dependencies, load-use hazards, branches, stalls, and flushes as those features are implemented.

GTKWave screenshots will remain as debugging and visualization evidence rather than the only source of verification.

## Next Milestones

1. Integrate the existing stages and four pipeline registers into an initial 5-stage pipeline, using a simplified MEM pass-through where memory behavior is not yet required.
2. Add instruction memory and data memory.
3. Complete control-signal propagation and the pipelined write-back path.
4. Add forwarding logic.
5. Add hazard detection and load-use stall handling.
6. Add branch decision and pipeline flush handling.
7. Extend the supported RV32I instruction subset.
8. Add self-checking, program-based end-to-end CPU verification.

An architecture diagram will be added once the stage-to-stage CPU datapath is genuinely integrated so that the diagram reflects the implemented design rather than a planned architecture.

## Project Structure

```text
riscv-5stage-cpu/
├── RTL/           # Verilog RTL modules
├── Testbench/     # Component and datapath testbenches
├── docs/
│   ├── notes/     # Development notes
│   └── waveforms/ # GTKWave screenshots
└── README.md
```

The development notes are retained as implementation history, while this README focuses on the current engineering state of the processor.

## Tools

- Verilog
- Icarus Verilog / vvp
- GTKWave
- VS Code
- Git / GitHub

## Development Status

This repository is actively being developed. The basic RTL building blocks, the ADD/SUB/ADDI pre-pipeline datapath, and all four standalone pipeline registers are implemented. The next major goal is to connect them into an initial 5-stage pipeline before adding memory behavior, forwarding, hazard handling, branches, and final program-level verification.
