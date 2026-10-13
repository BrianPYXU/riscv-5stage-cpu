# 5-Stage Pipelined RISC-V CPU (Work in Progress)

A work-in-progress 32-bit RISC-V processor implemented in Verilog and verified with Icarus Verilog, self-checking testbenches, and GTKWave.

The current design includes an integrated 5-stage pipeline:

```text
IF → ID → EX → MEM → WB
```

The processor currently supports arithmetic, logic, load/store, and branch instructions together with data forwarding, load-use hazard handling, control-hazard handling, store-data forwarding, and PC-based instruction fetching.

Currently implemented instructions:

```text
ADD
SUB
ADDI
AND
OR
XOR
SLT
LW
SW
BEQ
```

The processor fetches instructions directly from instruction memory using the program counter.

Data forwarding from both EX/MEM and MEM/WB is integrated for both ALU source operands. Store-data forwarding is also supported so recently generated register values can be stored to memory without waiting for register-file write-back.

A hazard detection unit handles load-use dependencies by holding the PC and IF/ID register while inserting a bubble into ID/EX.

BEQ is resolved in the EX stage. Taken branches redirect the PC and flush wrong-path instructions from IF/ID and ID/EX.

The processor is still under development. Additional RV32I support, regression-test cleanup, larger mixed-instruction programs, and final program-level verification remain in progress.

---

## Current Progress

### RTL Components

- [x] 32-bit Register
- [x] 32-bit 2-to-1 Multiplexer
- [x] 32-bit ALU
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

---

## Current Instruction Support

| Instruction | Type | Status |
| --- | --- | --- |
| ADD | R-type | Implemented |
| SUB | R-type | Implemented |
| AND | R-type | Implemented |
| OR | R-type | Implemented |
| XOR | R-type | Implemented |
| SLT | R-type | Implemented |
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

---

## ALU Operations

The current ALU control mapping is:

```text
0000 → ADD
0001 → SUB
0010 → AND
0011 → OR
0100 → XOR
0101 → SLT
```

### SLT

`SLT` performs signed comparison.

Example:

```text
-13 < 10 → 1
```

The ALU uses signed comparison so negative operands are handled correctly.

The signed behavior has been verified both at ALU level and through the full pipeline.

---

## Instruction Memory and PC-Based Fetch

A 256 x 32-bit instruction memory is integrated into the IF stage.

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

The fetch path is:

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

The following program was tested:

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

The data memory uses:

```text
Synchronous write
Combinational read
```

### SW

Example:

```assembly
sw x5, 8(x2)
```

The effective address is calculated in the EX stage and the value is written to data memory in MEM.

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

Both LW and SW have been verified through the full pipeline.

---

## Data Forwarding

Data forwarding is integrated into the EX stage to resolve RAW dependencies without waiting for normal register-file write-back.

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

Register `x0` is excluded from forwarding.

The MEM/WB forwarding path uses final `wb_data`, allowing forwarded results to represent either an ALU result or loaded memory data.

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

## Store-Data Forwarding

Store instructions also require the latest value of `rs2`.

Example:

```assembly
addi x5, x0, 10
sw   x5, 0(x2)
```

The store-data path uses the forwarded `rs2` value:

```verilog
.store_data_in(forward_b_data)
```

The resulting path is:

```text
Forwarded rs2
↓
EX/MEM store_data
↓
Data Memory write_data
```

A previous integration test verified:

```text
x5 = 10
memory[0] = 10
```

A dedicated regression testbench for this case will be preserved during the current testbench cleanup phase.

---

## Load-Use Hazard Detection

Forwarding alone cannot resolve a dependency where an instruction immediately following `LW` uses the loaded value.

Example:

```assembly
lw  x5, 0(x2)
add x6, x5, x3
```

The hazard detection unit checks:

```verilog
mem_read_ex &&
(rd_ex != 5'd0) &&
((rd_ex == rs1_id) || (rd_ex == rs2_id))
```

When detected:

```text
PC      → Hold
IF/ID   → Hold
ID/EX   → Flush / Insert Bubble
```

The load instruction continues forward while the dependent instruction waits one cycle.

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

A dedicated self-checking regression test is now stored as:

```text
Testbench/pipeline_load_use_tb.v
```

The simulation reports:

```text
ALL LOAD-USE PIPELINE TESTS PASSED
```

---

## Branch and Control Hazard Handling

`BEQ` support is integrated.

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

### Branch Decision

Branches are resolved in the EX stage.

Branch target:

```text
branch_target = pc_ex + immediate_ex
```

BEQ compares forwarded source values:

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

Both taken and not-taken BEQ paths have been verified.

---

## End-to-End Branch Fetch Verification

Branch handling has also been tested together with instruction-memory-based fetching.

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

The test passed successfully.

This verifies:

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

---

## Logic Instruction Verification

AND, OR, XOR, and SLT have been verified through the full 5-stage pipeline.

Test operands included:

```text
x1 = 12
x2 = 10
```

Expected results:

```text
AND → 8
OR  → 14
XOR → 6
SLT → 0
```

Signed SLT was also verified using a negative source operand:

```text
x4 = -13
x2 = 10

SLT → 1
```

A dedicated self-checking regression test is now stored as:

```text
Testbench/pipeline_logic_tb.v
```

The simulation reports:

```text
ALL PIPELINE TESTS PASSED
```

---

## Verification Strategy

Verification currently uses:

- dedicated Verilog testbenches
- Icarus Verilog
- `vvp`
- automatic PASS/FAIL checking
- GTKWave waveform inspection

GTKWave is used as visual evidence of timing and pipeline behavior rather than as the only verification method.

### Component-Level Verification

Verified modules include:

- Register File
- Program Counter
- Instruction Decoder
- Immediate Generator
- ALU
- Pipeline Registers
- Forwarding Unit
- Data Memory
- Instruction Memory
- Hazard Detection Unit

### Pipeline-Level Verification

Verified pipeline behaviors include:

- arithmetic execution
- logic execution
- signed SLT
- forwarding
- load/store execution
- load-use hazard stall
- store-data forwarding
- BEQ taken
- BEQ not taken
- branch flush
- PC redirect
- sequential instruction fetch
- branch target fetch

---

## Regression Test Cleanup

Earlier development reused `pipeline_top_tb.v` for multiple integration tests.

The current verification cleanup phase is preserving important tests as separate self-checking regression testbenches.

Currently preserved:

```text
pipeline_logic_tb.v
pipeline_load_use_tb.v
```

Planned regression tests include:

```text
pipeline_store_forwarding_tb.v
pipeline_branch_tb.v
pipeline_branch_fetch_tb.v
```

This allows previously verified behaviors to be re-run without overwriting older tests.

---

## Known Improvement

The current load-use hazard detector compares `rd_ex` with both `rs1_id` and `rs2_id`.

For I-type instructions such as ADDI and LW, instruction bits `[24:20]` are not always an actual `rs2` operand.

Therefore, some immediate values may cause an unnecessary stall if those bits happen to match `rd_ex`.

This does not normally produce an incorrect result, but it may reduce performance.

A future refinement will add source-usage information such as:

```text
uses_rs1
uses_rs2
```

so the hazard detector only checks registers actually used by the instruction.

---

## Remaining Work

The processor is not yet a complete RV32I CPU.

Completed:

- [x] 5-stage pipeline integration
- [x] Instruction Memory
- [x] Data Memory
- [x] PC-based instruction fetch
- [x] ADD
- [x] SUB
- [x] ADDI
- [x] AND
- [x] OR
- [x] XOR
- [x] SLT
- [x] LW
- [x] SW
- [x] BEQ
- [x] Data forwarding
- [x] Store-data forwarding
- [x] Load-use hazard handling
- [x] PC stall control
- [x] IF/ID stall control
- [x] Pipeline bubble insertion
- [x] Branch decision logic
- [x] Branch target generation
- [x] Pipeline flush on taken branches
- [x] Instruction-memory-based execution
- [x] Logic instruction regression test
- [x] Load-use regression test

Remaining:

- [ ] Preserve remaining regression tests
- [ ] Additional RV32I instructions if needed
- [ ] Improve hazard source-usage detection
- [ ] Create larger mixed-instruction test program
- [ ] Final end-to-end architectural verification
- [ ] Final waveform cleanup
- [ ] Final README cleanup

---

## Next Milestones

1. Preserve store-data forwarding as a dedicated regression test.
2. Preserve branch taken/not-taken tests.
3. Preserve branch target fetch verification.
4. Build a larger mixed instruction program.
5. Exercise arithmetic, logic, forwarding, memory, hazards, and branch behavior in one program.
6. Add final self-checking architectural verification.
7. Refine hazard detection to avoid unnecessary stalls.
8. Clean up representative GTKWave screenshots.
9. Finalize project documentation.

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
│   ├── pipeline_logic_tb.v
│   ├── pipeline_load_use_tb.v
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
│   │   ├── day17.md
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
AND
OR
XOR
SLT
LW
SW
BEQ
```

EX/MEM and MEM/WB forwarding are integrated for both ALU source operands. Store-data forwarding is also supported for dependent SW instructions.

Load-use hazards are handled by holding the PC and IF/ID register while inserting a bubble into ID/EX.

BEQ is resolved in the EX stage using forwarded operands. Taken branches redirect the PC and flush wrong-path instructions from IF/ID and ID/EX.

Instruction memory is integrated with the program counter, allowing sequential program execution and automatic branch-target fetching.

AND, OR, XOR, and signed SLT have now been integrated and verified through the full pipeline.

The project is currently transitioning from feature development toward stronger regression testing and final program-level verification.