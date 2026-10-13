# 5-Stage Pipelined RISC-V CPU (Work in Progress)

A work-in-progress 32-bit RISC-V processor implemented in Verilog and verified with Icarus Verilog, self-checking testbenches, and GTKWave.

The current design includes an integrated 5-stage pipeline:

```text
IF → ID → EX → MEM → WB
```

The processor currently supports arithmetic, load/store, and branch execution together with data forwarding, load-use hazard handling, control-hazard handling, and PC-based instruction fetching.

Currently implemented instructions:

```text
ADD
SUB
ADDI
LW
SW
BEQ
```

The processor now fetches instructions directly from instruction memory using the program counter.

Data forwarding from both EX/MEM and MEM/WB is integrated for both ALU source operands. Store-data forwarding is also supported so recently generated register values can be stored to memory without waiting for register-file write-back.

A hazard detection unit handles load-use dependencies by holding the PC and IF/ID register while inserting a bubble into ID/EX.

BEQ is resolved in the EX stage. Taken branches redirect the PC and flush wrong-path instructions from IF/ID and ID/EX.

The processor is still under development. Broader RV32I instruction support and larger program-level verification remain in progress.

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
- [x] Instruction Memory
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

The ID/EX register also propagates:

- `rs1`
- `rs2`
- branch control
- instruction PC

These signals are used for forwarding, hazard detection, and branch processing in the EX stage.

---

## 5-Stage Pipeline Integration

The current datapath is:

```text
Program Counter
      ↓
Instruction Memory
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

- [x] PC-based instruction fetch
- [x] IF → ID stage propagation
- [x] ID → EX stage propagation
- [x] EX → MEM stage propagation
- [x] MEM → WB stage propagation
- [x] Control-signal propagation across pipeline registers
- [x] Pipelined register-file write-back
- [x] ALU operand selection
- [x] WB selection using `mem_to_reg`
- [x] Data-memory access in MEM stage
- [x] Data forwarding
- [x] Store-data forwarding
- [x] Load-use hazard handling
- [x] Branch target generation
- [x] Branch redirect
- [x] Pipeline flush for taken branches
- [x] ADD execution
- [x] SUB execution
- [x] ADDI execution
- [x] LW execution
- [x] SW execution
- [x] BEQ execution

---

## Instruction Memory and PC-Based Fetch

A 256 x 32-bit instruction memory has been integrated into the IF stage.

```verilog
reg [31:0] memory [0:255];
```

Instruction memory uses combinational read:

```verilog
assign instruction = memory[address[9:2]];
```

Because RISC-V instructions are 4 bytes:

```text
PC = 0  → memory[0]
PC = 4  → memory[1]
PC = 8  → memory[2]
PC = 12 → memory[3]
```

The processor no longer requires the testbench to manually provide one instruction every cycle.

The fetch path is now:

```text
PC
↓
Instruction Memory
↓
instruction_if
↓
IF/ID
```

### Sequential Fetch Verification

The following program was loaded into instruction memory:

```assembly
addi x2, x0, 10
addi x3, x0, 20
add  x4, x2, x3
```

Expected final values:

```text
x2 = 10
x3 = 20
x4 = 30
```

The processor automatically fetched the instructions at PC values:

```text
0 → 4 → 8
```

and produced the expected architectural state.

The self-checking test reported:

```text
ALL INSTRUCTION FETCH TESTS PASSED
```

---

## Data Memory and Load/Store Support

A 256 x 32-bit data memory is implemented.

```verilog
reg [31:0] memory [0:255];
```

CPU addresses are byte addresses while the internal memory is word indexed.

Therefore:

```verilog
address[9:2]
```

is used as the memory index.

Example:

```text
CPU address = 12
12 / 4 = 3
→ memory[3]
```

The data memory currently uses:

```text
Synchronous write
Combinational read
```

### SW

Example:

```assembly
sw x5, 8(x2)
```

If:

```text
x2 = 4
x5 = 123
```

then:

```text
address = 4 + 8 = 12
memory[3] = 123
```

Pipeline-level verification confirmed correct store execution.

### LW

Example:

```assembly
lw x6, 8(x2)
```

The load path is:

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

Data forwarding is integrated into the EX stage to resolve RAW dependencies without waiting for normal register-file write-back.

The forwarding unit compares the EX-stage source registers against destination registers in EX/MEM and MEM/WB.

Forwarding selections:

```text
00 → original ID/EX value
10 → EX/MEM forwarding
01 → MEM/WB forwarding
```

Forwarding is implemented independently for:

```text
ForwardA → rs1 / ALU operand A
ForwardB → rs2 / ALU operand B
```

Priority:

```text
EX/MEM > MEM/WB
```

This ensures the newest available value is selected.

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

The MEM/WB forwarding path uses final `wb_data`, allowing forwarded results to represent either an ALU result or loaded memory data.

---

## Store-Data Forwarding

Store instructions also require the latest value of `rs2`.

For example:

```assembly
addi x5, x0, 10
sw   x5, 0(x2)
```

The updated value of `x5` may not yet be available in the register file when `SW` reads it.

The store-data path therefore uses the forwarded `rs2` value:

```verilog
.store_data_in(forward_b_data)
```

instead of the original ID/EX register value.

The resulting path is:

```text
Forwarded rs2
↓
EX/MEM store_data
↓
Data Memory write_data
```

### Store-Data Forwarding Verification

Test sequence:

```assembly
addi x5, x0, 10
sw   x5, 0(x2)
```

Initial state:

```text
x2 = 0
memory[0] = 0
```

Expected:

```text
x5 = 10
memory[0] = 10
```

Simulation produced:

```text
x5 = 0x0000000A
memory[0] = 0x0000000A
```

The self-checking test reported:

```text
ALL STORE-DATA FORWARDING TESTS PASSED
```

---

## Load-Use Hazard Detection

Forwarding cannot fully resolve every dependency.

A load-use hazard occurs when an instruction immediately following `LW` needs the value being loaded.

Example:

```assembly
lw  x5, 0(x2)
add x6, x5, x3
```

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

When true:

```text
hazard_stall = 1
```

---

## Load-Use Stall Handling

When a load-use hazard is detected:

```text
PC      → Hold
IF/ID   → Hold
ID/EX   → Flush / Insert Bubble
```

The load instruction continues into MEM while the dependent instruction remains in ID for one extra cycle.

Conceptually:

```text
Before:

EX = LW
ID = dependent ADD

After hazard handling:

MEM = LW
EX  = Bubble
ID  = dependent ADD
```

### Load-Use Verification

Test:

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

Expected:

```text
x5 = 12
x6 = 32
```

Simulation produced:

```text
x5 = 0x0000000C
x6 = 0x00000020
```

The waveform confirmed that `hazard_stall` was asserted for exactly one pipeline cycle.

The self-checking test reported:

```text
ALL LOAD-USE HAZARD TESTS PASSED
```

---

## Branch and Control Hazard Handling

`BEQ` support has been integrated.

BEQ encoding:

```text
opcode = 1100011
funct3 = 000
```

The decoder produces a `branch` control signal which is propagated through ID/EX into the EX stage.

### B-Type Immediate

The branch immediate is reconstructed from:

```text
imm[12]   = instruction[31]
imm[11]   = instruction[7]
imm[10:5] = instruction[30:25]
imm[4:1]  = instruction[11:8]
imm[0]    = 0
```

The sign-extended immediate is:

```verilog
{{19{instruction[31]}},
 instruction[31],
 instruction[7],
 instruction[30:25],
 instruction[11:8],
 1'b0}
```

### Branch Decision

Branches are resolved in the EX stage.

Branch target:

```text
branch_target = pc_ex + immediate_ex
```

BEQ compares the forwarded source values:

```verilog
branch_equal_ex =
    (alu_operand_a_ex == forward_b_data);
```

Branch taken:

```verilog
branch_taken_ex =
    branch_ex && branch_equal_ex;
```

Using forwarded values allows BEQ to depend on recently generated register results.

---

## Control Hazard Flush

If a branch is taken:

```text
PC      → branch target
IF/ID   → flush
ID/EX   → flush
```

This removes wrong-path instructions already fetched before the branch decision becomes available.

### Taken Branch Verification

Example:

```assembly
beq  x1, x2, +8
addi x5, x0, 99
```

With:

```text
x1 = 5
x2 = 5
```

the branch is taken and the ADDI is flushed.

Expected:

```text
x5 = 0
```

The test passed.

### Not-Taken Branch Verification

When:

```text
x1 != x2
```

the branch is not taken.

The next sequential instruction executes normally and no branch flush is performed.

This path was also verified successfully.

---

## End-to-End Branch Fetch Verification

Branch handling was also tested together with instruction-memory-based fetching.

Program:

```assembly
PC=0   beq  x1, x2, +8
PC=4   addi x5, x0, 99
PC=8   addi x6, x0, 42
```

Initial state:

```text
x1 = 5
x2 = 5
x5 = 0
x6 = 0
```

Because:

```text
x1 == x2
```

the branch is taken.

Expected behavior:

```text
PC=4 instruction → flushed
PC redirected to 8
PC=8 instruction → fetched and executed
```

Expected final state:

```text
x5 = 0
x6 = 42
```

Simulation produced:

```text
x5 = 0
x6 = 42
```

This verifies the complete branch path:

```text
BEQ decode
→ EX-stage comparison
→ branch taken
→ wrong-path flush
→ PC redirect
→ target instruction fetch
→ target execution
→ register write-back
```

The self-checking branch-fetch test passed successfully.

---

## Current Instruction Support

| Instruction | Type | Status |
| --- | --- | --- |
| ADD | R-type | Implemented |
| SUB | R-type | Implemented |
| ADDI | I-type | Implemented |
| LW | I-type | Implemented |
| SW | S-type | Implemented |
| BEQ | B-type | Implemented |

The immediate generator currently supports:

```text
I-type → ADDI, LW
S-type → SW
B-type → BEQ
```

Additional RV32I instructions will be added later.

---

## Verification Status

Verification currently uses:

- dedicated Verilog testbenches
- Icarus Verilog
- `vvp`
- automatic PASS/FAIL checking
- GTKWave waveform inspection

GTKWave is used as visual evidence of pipeline timing and internal behavior rather than as the only verification method.

### Component-Level Verification

Verified modules include:

- Register File
- Program Counter
- Instruction Decoder
- Immediate Generator
- IF/ID Register
- ID/EX Register
- EX/MEM Register
- MEM/WB Register
- Forwarding Unit
- Data Memory
- Instruction Memory
- Hazard Detection Unit

### Forwarding Verification

The forwarding unit has been tested for:

- no forwarding
- EX/MEM → A
- MEM/WB → A
- EX/MEM → B
- MEM/WB → B
- EX/MEM priority over MEM/WB
- x0 exclusion

A successful simulation reports:

```text
ALL FORWARDING TESTS PASSED
```

### Hazard Detection Verification

The hazard detection unit has been tested for:

- non-load instruction → no stall
- load destination matching `rs1`
- load destination matching `rs2`
- no dependency
- `rd = x0` exclusion

### Data Memory Verification

Data memory has been verified for:

- synchronous word write
- combinational word read
- byte-address to word-index conversion

### Instruction Memory Verification

Instruction memory has been verified for:

- combinational instruction read
- correct byte-address to word-index conversion
- sequential PC-based instruction fetching

---

## Pipeline-Level Verification

Pipeline-level testing currently includes:

### Independent Arithmetic Instructions

```assembly
addi x2, x1, 8
add  x3, x4, x5
sub  x6, x7, x8
```

Expected register values were correctly written back.

### Forwarding Dependencies

Example:

```assembly
addi x2, x0, 10
add  x3, x2, x4
```

The dependent instruction receives the new value through EX/MEM forwarding.

A larger forwarding test also verifies:

- EX/MEM forwarding
- MEM/WB forwarding
- both ALU operands
- forwarding priority

### Load/Store Execution

Both LW and SW have been verified through the full pipeline.

### Load-Use Dependency

```assembly
lw  x5, 0(x2)
add x6, x5, x3
```

Correct one-cycle stall behavior and final architectural results were verified.

### Store-Data Dependency

```assembly
addi x5, x0, 10
sw   x5, 0(x2)
```

Store-data forwarding correctly writes the newest `x5` value to memory.

### Branch Execution

Both taken and not-taken BEQ paths have been verified.

### PC-Based Program Execution

The processor can now automatically fetch and execute a small program directly from instruction memory.

---

## Example Forwarding Test Results

A forwarding test sequence produced the following expected final values:

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

All values were automatically checked by the testbench.

---

## Remaining Work

The processor is not yet a complete RV32I CPU.

Completed:

- [x] 5-stage pipeline integration
- [x] Data forwarding
- [x] Data Memory
- [x] Instruction Memory
- [x] PC-based instruction fetch
- [x] LW support
- [x] SW support
- [x] Store-data forwarding
- [x] Hazard Detection Unit
- [x] Load-use stall handling
- [x] PC stall control
- [x] IF/ID stall control
- [x] Pipeline bubble insertion
- [x] BEQ support
- [x] Branch decision logic
- [x] Branch target generation
- [x] PC redirect
- [x] Pipeline flush on taken branches
- [x] Instruction-memory-based program execution
- [x] Basic end-to-end branch verification

Remaining:

- [ ] Broader RV32I instruction support
- [ ] Additional ALU operations
- [ ] Larger multi-instruction test programs
- [ ] More dependency and corner-case testing
- [ ] Final end-to-end architectural verification
- [ ] Final documentation and waveform cleanup

---

## Next Milestones

1. Add additional RV32I ALU instructions such as AND, OR, XOR, and SLT.
2. Extend decoder and ALU control support.
3. Verify the new instructions independently.
4. Create a larger mixed instruction program.
5. Exercise forwarding, load-use stalls, memory operations, and branches in one program.
6. Add final self-checking architectural verification.
7. Clean up representative GTKWave screenshots.
8. Finalize README and project documentation.

---

## Project Structure

```text
riscv-5stage-cpu/
├── RTL/
│   ├── pipeline_top.v
│   ├── program_counter.v
│   ├── instruction_memory.v
│   ├── instruction_decoder.v
│   ├── immediate_generator.v
│   ├── register_file.v
│   ├── alu.v
│   ├── mux2.v
│   ├── forwarding_unit.v
│   ├── hazard_detection_unit.v
│   ├── data_memory.v
│   ├── if_id_register.v
│   ├── id_ex_register.v
│   ├── ex_mem_register.v
│   ├── mem_wb_register.v
│   └── ...
│
├── Testbench/
│   ├── pipeline_top_tb.v
│   ├── forwarding_unit_tb.v
│   ├── hazard_detection_unit_tb.v
│   ├── data_memory_tb.v
│   ├── instruction_memory_tb.v
│   └── ...
│
├── docs/
│   ├── notes/
│   │   ├── day12.md
│   │   ├── day13.md
│   │   ├── day14.md
│   │   ├── day15.md
│   │   ├── day16.md
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

The processor currently contains an integrated 5-stage IF/ID/EX/MEM/WB pipeline capable of automatically fetching and executing instructions from instruction memory.

Current implemented instructions include:

```text
ADD
SUB
ADDI
LW
SW
BEQ
```

EX/MEM and MEM/WB forwarding are integrated for both ALU source operands. Store-data forwarding is also supported for dependent SW instructions.

Load-use hazards are handled by holding the PC and IF/ID register while inserting a bubble into ID/EX.

BEQ is resolved in the EX stage using forwarded operands. Taken branches redirect the PC and flush wrong-path instructions from IF/ID and ID/EX.

Instruction memory is integrated with the program counter, allowing the processor to execute sequential programs and automatically fetch branch target instructions.

The next major development step is broader RV32I instruction support, followed by larger mixed-instruction program testing and final architectural verification.