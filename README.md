# 5-Stage Pipelined RISC-V CPU (Work in Progress)

A work-in-progress 32-bit RISC-V processor implemented in Verilog and verified with Icarus Verilog, self-checking testbenches, and GTKWave.

The current design includes an integrated 5-stage pipeline:

```text
IF → ID → EX → MEM → WB
```

The processor currently supports basic arithmetic instructions together with load/store execution, data forwarding, and load-use hazard handling.

Implemented instructions currently include:

```text
ADD
SUB
ADDI
LW
SW
```

Data forwarding from both EX/MEM and MEM/WB has been integrated for both ALU source operands.

A hazard detection unit has also been added to detect load-use dependencies. When required, the processor stalls the PC and IF/ID register while inserting a bubble into the ID/EX stage.

The processor is still under development. Instruction-memory-based fetching, branch handling, broader RV32I instruction support, and final program-level verification remain in progress.

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
- [x] Data Memory
- [x] Hazard Detection Unit

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

The ID/EX register also propagates source register indices (`rs1` and `rs2`) for forwarding and hazard-related decisions.

---

## 5-Stage Pipeline Integration

The pipelined datapath is currently integrated as:

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
- [x] Data-memory access in MEM stage
- [x] ADD execution
- [x] SUB execution
- [x] ADDI execution
- [x] LW execution
- [x] SW execution

The processor currently receives instructions through the external `instruction` input of `pipeline_top`.

A dedicated instruction memory and program-driven fetch path have not yet been integrated.

---

## Data Memory and Load/Store Support

A simple 32-bit word-based data memory has been implemented.

The current memory contains:

```text
256 words × 32 bits
```

CPU addresses are byte addresses, while the internal memory is word indexed.

Therefore the memory index is selected using:

```verilog
address[9:2]
```

For example:

```text
CPU address = 12
12 / 4 = 3
→ memory[3]
```

The memory currently uses:

```text
Synchronous write
Combinational read
```

### SW

`SW` stores a register value into data memory.

Example:

```assembly
sw x5, 8(x2)
```

The effective address is calculated in the EX stage:

```text
address = x2 + 8
```

The register value is then written to data memory in the MEM stage.

A pipeline-level SW test verified:

```text
x2 = 4
x5 = 123

sw x5, 8(x2)

address = 12
memory[3] = 123
```

### LW

`LW` loads a 32-bit word from memory and writes the result back into a register.

Example:

```assembly
lw x6, 8(x2)
```

The current load path is:

```text
Base Register + Immediate
          ↓
         ALU
          ↓
       EX/MEM
          ↓
      Data Memory
          ↓
       MEM/WB
          ↓
     mem_to_reg MUX
          ↓
      Register File
```

A pipeline-level test successfully loaded:

```text
memory[3] = 123
```

into:

```text
x6 = 123
```

---

## Data Forwarding

Data forwarding has been integrated into the EX stage to resolve basic RAW dependencies without waiting for normal register-file write-back.

The forwarding unit compares the source registers of the instruction currently in EX with destination registers in later pipeline stages.

Supported forwarding selections:

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

This ensures that the newest available value is selected when both later stages contain a matching destination register.

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

The MEM/WB forwarding path uses final `wb_data`, allowing the forwarded value to represent either an ALU result or a loaded memory value.

---

## Load-Use Hazard Detection

Forwarding alone cannot resolve every dependency.

A load-use hazard occurs when an instruction immediately after `LW` needs the value being loaded.

Example:

```assembly
lw  x5, 0(x2)
add x6, x5, x3
```

The `ADD` needs `x5` before the `LW` result is available.

The hazard detection unit checks:

```text
mem_read_ex = 1
rd_ex != x0
rd_ex == rs1_id OR rd_ex == rs2_id
```

Equivalent condition:

```verilog
mem_read_ex &&
(rd_ex != 5'd0) &&
((rd_ex == rs1_id) || (rd_ex == rs2_id))
```

When this condition is true:

```text
hazard_stall = 1
```

---

## Load-Use Stall Handling

When a load-use hazard is detected, the processor performs three actions:

```text
PC      → Hold
IF/ID   → Hold
ID/EX   → Flush / Insert Bubble
```

The load instruction itself is allowed to continue into the MEM stage.

The dependent instruction remains in ID for one extra cycle.

Conceptually:

```text
Before stall:

EX  = LW
ID  = dependent ADD

After hazard handling:

MEM = LW
EX  = Bubble
ID  = dependent ADD
```

After one cycle, the dependent instruction can continue.

### Load-Use Verification

The following sequence was tested:

```assembly
lw  x5, 0(x2)
add x6, x5, x3
```

Initial state:

```text
x2 = 0
x3 = 20
memory[0] = 12
```

Expected results:

```text
x5 = 12
x6 = 32
```

Simulation produced:

```text
x5 = 0x0000000C
x6 = 0x00000020
```

The waveform also confirmed that:

```text
hazard_stall = 1
```

for exactly one pipeline cycle.

The self-checking pipeline test reports:

```text
ALL LOAD-USE HAZARD TESTS PASSED
```

---

## Current Instruction Support

The integrated pipeline currently supports:

| Instruction | Type | Status |
| --- | --- | --- |
| ADD | R-type | Implemented |
| SUB | R-type | Implemented |
| ADDI | I-type | Implemented |
| LW | I-type | Implemented |
| SW | S-type | Implemented |

The immediate generator currently supports:

```text
I-type immediate → ADDI, LW
S-type immediate → SW
```

Additional RV32I instruction formats will be added later.

---

## Verification Status

Verification currently uses:

- dedicated Verilog testbenches
- Icarus Verilog / `vvp`
- automatic PASS/FAIL checking
- GTKWave waveform inspection

### Component-Level Verification

Individual RTL modules and pipeline registers have dedicated testbenches.

Verified modules include:

- Register File
- Program Counter
- Instruction Decoder
- Immediate Generator
- Pipeline Registers
- Forwarding Unit
- Data Memory
- Hazard Detection Unit

### Forwarding Unit Verification

The forwarding unit has been independently tested for:

- no forwarding
- EX/MEM → A
- MEM/WB → A
- EX/MEM → B
- MEM/WB → B
- EX/MEM priority over MEM/WB
- x0 exclusion

The forwarding testbench uses automatic expected-result checking.

### Hazard Detection Verification

The hazard detection unit has been independently tested for:

- non-load instruction → no stall
- load destination matching `rs1`
- load destination matching `rs2`
- no source-register match
- `rd = x0` exclusion

The testbench automatically checks the expected value of `stall`.

### Data Memory Verification

Data memory has been independently verified for:

- synchronous word write
- combinational word read
- byte-address to word-index conversion

Example:

```text
address = 12
memory index = 3
write_data = 123
```

The expected value was correctly stored and read back.

---

## Pipeline-Level Verification

The integrated pipeline was first verified using independent arithmetic instructions:

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

The second instruction receives the new value of `x2` through EX/MEM forwarding instead of waiting for register-file write-back.

A larger forwarding test sequence verifies EX/MEM and MEM/WB forwarding for both ALU operands together with priority handling.

Load/store execution has also been verified through the full pipeline.

Finally, a dependent `LW → ADD` sequence was used to verify load-use hazard detection, PC/IF-ID stalling, bubble insertion, and correct execution after the stall.

Expected architectural register values are checked automatically by the testbench.

GTKWave is used as visual evidence of timing and pipeline behavior rather than as the only verification method.

---

## Example Forwarding Test Results

The forwarding integration test verifies a sequence containing multiple RAW dependencies.

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

A successful forwarding simulation reports:

```text
ALL FORWARDING TESTS PASSED
```

The current load-use hazard test also performs automatic checking of the final architectural state.

A successful hazard simulation reports:

```text
ALL LOAD-USE HAZARD TESTS PASSED
```

---

## Remaining Work

The processor is not yet a complete RV32I CPU.

The main remaining features are:

- [ ] Instruction Memory / Fetch Integration
- [x] Data Memory
- [x] LW Support
- [x] SW Support
- [x] Hazard Detection Unit
- [x] Load-Use Stall Handling
- [x] PC Stall Control
- [x] IF/ID Stall Control
- [x] Pipeline Bubble Insertion
- [ ] Branch Decision Logic
- [ ] Branch Target Generation
- [ ] Pipeline Flush on Taken Branches
- [ ] Broader RV32I Instruction Support
- [ ] Instruction-Memory-Based Program Execution
- [ ] End-to-End Architectural Verification

### Possible Datapath Improvements

Store-data forwarding is not yet fully handled.

The current EX/MEM store-data path uses the register value propagated from ID/EX.

A future improvement can forward the newest `rs2` value into the store-data path so sequences such as:

```assembly
addi x5, x0, 10
sw   x5, 0(x2)
```

can execute correctly without requiring additional spacing.

---

## Next Milestones

1. Add branch decision logic.
2. Add branch target generation.
3. Add pipeline flush handling for taken branches.
4. Expand the supported RV32I instruction subset.
5. Add instruction memory and instruction-fetch integration.
6. Add instruction-memory-based program execution.
7. Improve store-data forwarding.
8. Add larger self-checking instruction sequences.
9. Add final program-level CPU verification.

---

## Project Structure

```text
riscv-5stage-cpu/
├── RTL/
│   ├── pipeline_top.v
│   ├── forwarding_unit.v
│   ├── hazard_detection_unit.v
│   ├── data_memory.v
│   ├── program_counter.v
│   ├── instruction_decoder.v
│   ├── immediate_generator.v
│   └── ...
│
├── Testbench/
│   ├── pipeline_top_tb.v
│   ├── forwarding_unit_tb.v
│   ├── hazard_detection_unit_tb.v
│   ├── data_memory_tb.v
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
- `vvp`
- GTKWave
- VS Code
- Git
- GitHub

---

## Development Status

This repository is actively being developed.

The current processor contains an integrated 5-stage IF/ID/EX/MEM/WB datapath capable of executing:

```text
ADD
SUB
ADDI
LW
SW
```

EX/MEM and MEM/WB forwarding have been integrated for both ALU source operands and verified using self-checking dependent-instruction tests.

A data-memory datapath has been integrated into the MEM stage, allowing both load and store instructions to execute through the pipeline.

A load-use hazard detection unit has also been integrated. When a dependent instruction immediately follows a load, the processor holds the PC and IF/ID register while inserting a bubble into ID/EX. The mechanism has been verified using a dependent `LW → ADD` sequence and automatic architectural-result checking.

The next major development step is branch and control-hazard handling, followed by broader RV32I support, instruction-memory-based execution, and final program-level CPU verification.