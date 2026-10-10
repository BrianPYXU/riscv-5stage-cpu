# 5-Stage Pipelined RISC-V CPU (Work in Progress)

A work-in-progress 32-bit RISC-V processor implemented in Verilog and verified with Icarus Verilog, self-checking testbenches, and GTKWave.

The current design includes an integrated 5-stage pipeline:

```text
IF → ID → EX → MEM → WB
```

ADD, SUB, and ADDI instructions can currently execute through the pipelined datapath. Data forwarding from both EX/MEM and MEM/WB has also been integrated for both ALU operands, allowing basic RAW dependencies to execute correctly without waiting for register-file write-back.

The processor is still under development. Instruction memory, data memory, load/store execution, load-use stall handling, branch handling, broader RV32I support, and final program-level verification remain in progress.

---

## Current Progress

### RTL Components

- [x] 32-bit Register
- [x] 32-bit 2-to-1 Multiplexer
- [x] Basic 32-bit ALU
- [x] Register File
- [x] Program Counter
- [x] Instruction Decoder
- [x] Immediate Generator
- [x] Forwarding Unit

### Pipeline Registers

- [x] IF/ID Pipeline Register
- [x] ID/EX Pipeline Register
- [x] EX/MEM Pipeline Register
- [x] MEM/WB Pipeline Register

Each pipeline register has been independently tested for:

- reset
- normal update
- stall
- flush

The ID/EX register also propagates source register indices (`rs1` and `rs2`) for forwarding decisions in the EX stage.

---

## 5-Stage Pipeline Integration

The basic pipelined datapath is now integrated:

```text
Instruction Input
      ↓
     IF
      ↓
    IF/ID
      ↓
     ID
      ↓
    ID/EX
      ↓
     EX
      ↓
   EX/MEM
      ↓
     MEM
      ↓
   MEM/WB
      ↓
     WB
      ↓
Register File
```

Current pipeline integration includes:

- [x] IF → ID stage propagation
- [x] ID → EX stage propagation
- [x] EX → MEM stage propagation
- [x] MEM → WB stage propagation
- [x] Control-signal propagation across pipeline registers
- [x] Pipelined register-file write-back
- [x] ALU operand selection
- [x] WB selection using `mem_to_reg`
- [x] Execution of ADD, SUB, and ADDI through the pipeline

The current MEM stage uses a simplified pass-through path because data memory has not yet been implemented.

---

## Data Forwarding

Data forwarding has been integrated into the EX stage to resolve basic RAW dependencies.

The forwarding unit compares the source registers of the instruction currently in EX with destination registers in later pipeline stages.

Supported forwarding paths:

```text
00 → original ID/EX register value
10 → EX/MEM forwarding
01 → MEM/WB forwarding
```

Forwarding is implemented independently for:

```text
ForwardA → ALU operand A / rs1
ForwardB → ALU operand B / rs2
```

Priority is:

```text
EX/MEM > MEM/WB
```

This ensures that the newest available value is selected when both stages contain a matching destination register.

Register `x0` is excluded from forwarding because it is permanently hardwired to zero.

### Forwarding Status

- [x] EX/MEM → Operand A
- [x] MEM/WB → Operand A
- [x] EX/MEM → Operand B
- [x] MEM/WB → Operand B
- [x] EX/MEM priority over MEM/WB
- [x] x0 forwarding exclusion
- [x] Forwarding integrated into `pipeline_top`
- [x] Dependent instruction sequences verified

---

## Current Instruction Support

The integrated pipeline currently supports:

| Instruction | Type | Status |
| --- | --- | --- |
| ADD | R-type | Implemented |
| SUB | R-type | Implemented |
| ADDI | I-type | Implemented |

The immediate generator also supports S-type immediate extraction in preparation for store instructions.

However, `LW` and `SW` execution are not yet supported because the data-memory datapath has not been implemented.

---

## Verification Status

Verification currently uses:

- dedicated Verilog testbenches
- Icarus Verilog / `vvp`
- automatic PASS/FAIL checking
- GTKWave waveform inspection

### Component-Level Verification

Individual RTL modules and pipeline registers have dedicated testbenches.

The forwarding unit has been independently tested for:

- no forwarding
- EX/MEM → A
- MEM/WB → A
- EX/MEM → B
- MEM/WB → B
- EX/MEM priority over MEM/WB
- x0 exclusion

The forwarding-unit testbench uses automatic expected-result checking.

### Pipeline-Level Verification

The integrated pipeline was first verified using independent instructions:

```assembly
addi x2, x1, 8
add  x3, x4, x5
sub  x6, x7, x8
```

The expected register results were correctly written back through the pipeline.

Forwarding was then verified using dependent instruction sequences.

Example:

```assembly
addi x2, x0, 10
add  x3, x2, x4
```

The second instruction receives the new value of `x2` through EX/MEM forwarding rather than waiting for register-file write-back.

A larger forwarding test sequence verifies EX/MEM and MEM/WB forwarding for both ALU operands, together with priority handling.

Expected architectural register values are checked automatically by the testbench.

A successful simulation reports:

```text
ALL FORWARDING TESTS PASSED
```

GTKWave is used as visual evidence of pipeline timing and forwarding behavior rather than as the only verification method.

---

## Example Forwarding Test Results

The current forwarding integration test verifies a sequence containing multiple RAW dependencies.

Expected final values include:

```text
x2  = 10
x3  = 30
x5  = 12
x6  = 32
x7  = 7
x8  = 27
x9  = 1
x10 = 9
x11 = 1
x12 = 29
x13 = 7
x14 = 27
x15 = 40
```

All values are automatically checked by the pipeline testbench.

---

## Remaining Work

The processor is not yet a complete RV32I CPU.

The main remaining features are:

- [ ] Instruction Memory / Fetch Integration
- [ ] Data Memory
- [ ] LW support
- [ ] SW support
- [ ] Hazard Detection Unit
- [ ] Load-Use Stall Handling
- [ ] PC stall control
- [ ] IF/ID stall control
- [ ] Pipeline bubble insertion
- [ ] Branch decision logic
- [ ] Branch target generation
- [ ] Pipeline flush on taken branches
- [ ] Broader RV32I instruction support
- [ ] Program-level instruction execution
- [ ] End-to-end architectural verification

Store-data forwarding may also be added when the SW datapath is implemented.

---

## Next Milestones

1. Implement hazard detection and load-use stall handling.
2. Add instruction memory.
3. Add data memory and complete LW/SW execution.
4. Add PC and IF/ID stall control.
5. Add pipeline bubble insertion for load-use hazards.
6. Add branch decision, target generation, and pipeline flush handling.
7. Expand the supported RV32I instruction subset.
8. Add instruction-memory-based program execution.
9. Add final self-checking program-level CPU verification.

---

## Project Structure

```text
riscv-5stage-cpu/
├── RTL/
│   ├── pipeline_top.v
│   ├── forwarding_unit.v
│   └── ...
│
├── Testbench/
│   ├── pipeline_top_tb.v
│   ├── forwarding_unit_tb.v
│   └── ...
│
├── docs/
│   ├── notes/
│   │   ├── day12.md
│   │   ├── day13.md
│   │   └── ...
│   │
│   └── waveforms/
│       ├── pipeline_top_waveform.png
│       ├── forwarding_unit_waveform.png
│       ├── forwarding_integration_waveform.png
│       └── ...
│
└── README.md
```

Development notes are retained as implementation history, while this README describes the current engineering state of the processor.

---

## Tools

- Verilog
- Icarus Verilog
- vvp
- GTKWave
- VS Code
- Git
- GitHub

---

## Development Status

This repository is actively being developed.

The current processor has an integrated 5-stage IF/ID/EX/MEM/WB datapath capable of executing ADD, SUB, and ADDI instructions. EX/MEM and MEM/WB forwarding have been integrated for both ALU operands and verified using self-checking dependent-instruction tests.

The next major development step is hazard detection and load-use stall handling, followed by memory integration, branch handling, broader RV32I support, and final program-level CPU verification.