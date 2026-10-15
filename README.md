# 5-Stage Pipelined RISC-V CPU

A 32-bit 5-stage pipelined RISC-V processor implemented in Verilog.

The processor includes instruction fetch, register decoding, ALU execution, data memory access, register write-back, data forwarding, load-use hazard handling, branch flushing, and self-checking verification.

The project was developed and verified using Icarus Verilog, `vvp`, and GTKWave.

> This project implements a selected subset of RV32I instructions for studying and demonstrating pipelined CPU architecture. It is not intended to be a complete RV32I implementation.

---

## Project Status

**Completed for the current project scope.**

The final regression suite passed all key tests, including forwarding, hazards, branch handling, memory access, logic instructions, and mixed-program execution.

---

## Architecture

The processor uses a classic 5-stage pipeline:

```text
IF → ID → EX → MEM → WB
```

### Pipeline Stages

```text
IF
│
├── Program Counter
├── Instruction Memory
│
▼
IF/ID
│
▼
ID
│
├── Instruction Decoder
├── Register File
├── Immediate Generator
│
▼
ID/EX
│
▼
EX
│
├── ALU
├── Forwarding
├── Branch Comparison
├── Branch Target Generation
│
▼
EX/MEM
│
▼
MEM
│
├── Data Memory
│
▼
MEM/WB
│
▼
WB
│
└── Register File Write Back
```

---

## Supported Instructions

The current processor supports:

| Instruction | Type | Operation |
| --- | --- | --- |
| ADD | R-type | Addition |
| SUB | R-type | Subtraction |
| AND | R-type | Bitwise AND |
| OR | R-type | Bitwise OR |
| XOR | R-type | Bitwise XOR |
| SLT | R-type | Signed less-than comparison |
| ADDI | I-type | Immediate addition |
| LW | I-type | Load word |
| SW | S-type | Store word |
| BEQ | B-type | Branch if equal |

---

## ALU Operations

The ALU uses the following control encoding:

```text
0000 → ADD
0001 → SUB
0010 → AND
0011 → OR
0100 → XOR
0101 → SLT
```

`SLT` performs signed comparison:

```verilog
result = ($signed(a) < $signed(b)) ? 32'd1 : 32'd0;
```

Example:

```text
-13 < 10 → 1
```

---

## Instruction Fetch

The processor contains a 256 x 32-bit instruction memory.

```verilog
reg [31:0] memory [0:255];
```

Instructions are fetched using the program counter:

```verilog
assign instruction = memory[address[9:2]];
```

Because every RISC-V instruction is 4 bytes:

```text
PC = 0   → memory[0]
PC = 4   → memory[1]
PC = 8   → memory[2]
PC = 12  → memory[3]
```

The fetch path is:

```text
Program Counter
      ↓
Instruction Memory
      ↓
    IF/ID
      ↓
      ID
```

---

## Data Memory

The processor contains a 256 x 32-bit data memory.

```verilog
reg [31:0] memory [0:255];
```

The CPU uses byte addresses while the memory is internally word indexed:

```verilog
memory[address[9:2]]
```

The current memory model uses:

```text
Combinational read
Synchronous write
```

---

## Data Forwarding

RAW dependencies are handled with forwarding from:

```text
EX/MEM
MEM/WB
```

Forwarding is implemented independently for both source operands.

Forwarding control:

```text
00 → Original ID/EX value
01 → MEM/WB forwarding
10 → EX/MEM forwarding
```

Priority:

```text
EX/MEM > MEM/WB
```

Register `x0` is excluded from forwarding.

### Example

```assembly
addi x1, x0, 12
addi x2, x0, 10
add  x3, x1, x2
```

The ADD can receive recently generated operands through forwarding without waiting for normal register-file write-back.

---

## Store-Data Forwarding

Store instructions also require the latest value of `rs2`.

Example:

```assembly
addi x5, x0, 10
sw   x5, 0(x2)
```

The value produced by ADDI is forwarded directly into the store-data path.

```text
Forwarded rs2
     ↓
EX/MEM store_data
     ↓
Data Memory write_data
```

---

## Load-Use Hazard Detection

Forwarding alone cannot resolve an instruction that immediately uses a value being loaded from memory.

Example:

```assembly
lw  x5, 0(x2)
add x6, x5, x3
```

The processor detects the dependency and performs:

```text
PC      → Hold
IF/ID   → Hold
ID/EX   → Flush / Insert Bubble
```

The dependent instruction waits one cycle while the load continues through the pipeline.

---

## Source-Aware Hazard Detection

The hazard detector also tracks whether the ID-stage instruction actually uses `rs1` and `rs2`.

The decoder generates:

```text
uses_rs1
uses_rs2
```

Current source usage:

| Instruction | uses_rs1 | uses_rs2 |
| --- | ---: | ---: |
| ADD | 1 | 1 |
| SUB | 1 | 1 |
| AND | 1 | 1 |
| OR | 1 | 1 |
| XOR | 1 | 1 |
| SLT | 1 | 1 |
| ADDI | 1 | 0 |
| LW | 1 | 0 |
| SW | 1 | 1 |
| BEQ | 1 | 1 |

The load-use condition is:

```verilog
mem_read_ex &&
(rd_ex != 5'd0) &&
(
    (uses_rs1 && rd_ex == rs1_id) ||
    (uses_rs2 && rd_ex == rs2_id)
)
```

This prevents unnecessary stalls caused by instruction bits that resemble an `rs2` field but are actually part of an immediate value.

---

## Branch Handling

`BEQ` is resolved in the EX stage.

Branch target:

```verilog
branch_target_ex = pc_ex + immediate_ex;
```

Branch comparison:

```verilog
branch_equal_ex =
    (alu_operand_a_ex == forward_b_data);
```

Branch decision:

```verilog
branch_taken_ex =
    branch_ex && branch_equal_ex;
```

Forwarded operands are used for branch comparison, allowing BEQ to depend on recently generated register values.

---

## Control Hazard Handling

When a branch is taken:

```text
PC      → Branch Target
IF/ID   → Flush
ID/EX   → Flush
```

Wrong-path instructions already inside the pipeline are removed.

Example:

```assembly
beq  x1, x2, +8
addi x5, x0, 99
addi x6, x0, 42
```

If:

```text
x1 = x2
```

then:

```text
x5 remains 0
x6 becomes 42
```

This verifies:

```text
Branch decision
Wrong-path flush
PC redirect
Branch-target fetch
Target execution
```

---

## Pipeline Registers

The processor contains four pipeline registers:

```text
IF/ID
ID/EX
EX/MEM
MEM/WB
```

The pipeline registers support:

```text
Reset
Normal update
Stall
Flush
```

The ID/EX register carries information required by later stages, including:

```text
rs1
rs2
PC
branch control
ALU control
memory control
write-back control
```

---

## Final Mixed Program Verification

A larger mixed program was created to verify multiple processor features together.

```assembly
addi x1,  x0, 12
addi x2,  x0, 10

add  x3,  x1, x2

sw   x3,  0(x0)

lw   x9,  0(x0)
add  x10, x9, x2

sub  x4,  x1, x2
and  x5,  x1, x2
or   x6,  x1, x2
xor  x7,  x1, x2
slt  x8,  x2, x1

beq  x9,  x3, +8

addi x11, x0, 99
addi x12, x0, 42
```

This single program exercises:

```text
ADDI
ADD
SUB
AND
OR
XOR
SLT
LW
SW
BEQ

EX/MEM forwarding
MEM/WB forwarding
Store-data forwarding
Load-use stall
Data-memory access
Branch comparison
Branch flush
PC redirect
Branch-target fetch
Write-back
```

Expected architectural state:

```text
x1  = 12
x2  = 10
x3  = 22
x4  = 2
x5  = 8
x6  = 14
x7  = 6
x8  = 1
x9  = 22
x10 = 32
x11 = 0
x12 = 42

memory[0] = 22
```

The self-checking test reports:

```text
ALL FINAL MIXED PIPELINE TESTS PASSED
```

with:

```text
errors = 0
```

---

## Verification

Verification uses:

```text
Icarus Verilog
vvp
GTKWave
Self-checking Verilog testbenches
```

GTKWave is used for visual timing inspection, while automatic self-checking testbenches determine PASS/FAIL results.

### Final Regression Status

The final key regression suite passed:

```text
8 / 8 tests passed
```

Verified tests:

```text
hazard_detection_unit_tb
forwarding_unit_tb
pipeline_logic_tb
pipeline_load_use_tb
pipeline_store_forwarding_tb
pipeline_branch_tb
pipeline_branch_fetch_tb
pipeline_final_tb
```

### Standalone Tests

Additional module-level tests include:

```text
alu_tb.v
data_memory_tb.v
forwarding_unit_tb.v
hazard_detection_unit_tb.v
immediate_generator_tb.v
instruction_decoder_tb.v
instruction_memory_tb.v
program_counter_tb.v
register_file_tb.v
if_id_register_tb.v
id_ex_register_tb.v
ex_mem_register_tb.v
mem_wb_register_tb.v
mux2_tb.v
```

### Pipeline Regression Tests

Important pipeline-level regression tests include:

```text
pipeline_logic_tb.v
pipeline_load_use_tb.v
pipeline_store_forwarding_tb.v
pipeline_branch_tb.v
pipeline_branch_fetch_tb.v
pipeline_final_tb.v
```

---

## Regression Coverage

Current verification covers:

```text
Arithmetic execution
Logic execution
Signed SLT
EX/MEM forwarding
MEM/WB forwarding
Store-data forwarding
LW execution
SW execution
Load-use hazard detection
False-hazard filtering
BEQ taken
BEQ not taken
Branch operand forwarding
Wrong-path flush
PC redirect
Sequential instruction fetch
Branch-target fetch
Register write-back
Final mixed-program execution
```

---

## Representative Waveforms

Representative GTKWave results are stored under:

```text
docs/waveforms/
```

Important examples include:

```text
pipeline_final_waveform.png
pipeline_branch_fetch_waveform.png
hazard_detection_unit_waveform.png
forwarding_integration_waveform.png
data_memory_waveform.png
```

These waveforms provide visual verification of:

```text
Mixed-program execution
Branch redirect and flush
Source-aware hazard detection
Forwarding behavior
Memory access
```

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
│   └── mem_wb_register.v
│
├── Testbench/
│   ├── alu_tb.v
│   ├── data_memory_tb.v
│   ├── forwarding_unit_tb.v
│   ├── hazard_detection_unit_tb.v
│   ├── immediate_generator_tb.v
│   ├── instruction_decoder_tb.v
│   ├── instruction_memory_tb.v
│   ├── program_counter_tb.v
│   ├── register_file_tb.v
│   ├── if_id_register_tb.v
│   ├── id_ex_register_tb.v
│   ├── ex_mem_register_tb.v
│   ├── mem_wb_register_tb.v
│   ├── mux2_tb.v
│   ├── pipeline_logic_tb.v
│   ├── pipeline_load_use_tb.v
│   ├── pipeline_store_forwarding_tb.v
│   ├── pipeline_branch_tb.v
│   ├── pipeline_branch_fetch_tb.v
│   └── pipeline_final_tb.v
│
├── docs/
│   ├── notes/
│   │   ├── day01.md
│   │   ├── day02.md
│   │   ├── ...
│   │   ├── day17.md
│   │   └── day18.md
│   │
│   └── waveforms/
│       ├── pipeline_final_waveform.png
│       ├── pipeline_branch_fetch_waveform.png
│       ├── hazard_detection_unit_waveform.png
│       ├── forwarding_integration_waveform.png
│       └── ...
│
└── README.md
```

---

## Development Notes

Development notes are stored under:

```text
docs/notes/
```

They document the project incrementally from basic RTL modules to complete pipeline integration.

Topics include:

```text
RTL fundamentals
Register file
Program counter
Instruction decoding
Immediate generation
Pipeline registers
Pipeline integration
Forwarding
Load/store support
Load-use hazards
Branch handling
Instruction memory
Logic instructions
Regression testing
Final mixed-program verification
Hazard detection refinement
```

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

## Final Status

The project is complete for the current scope.

Implemented features include:

```text
5-stage IF/ID/EX/MEM/WB pipeline
PC-based instruction fetch
Instruction memory
Register file
ALU
Data memory
Pipeline registers
EX/MEM forwarding
MEM/WB forwarding
Store-data forwarding
Load-use hazard handling
Source-aware hazard detection
BEQ execution
Forwarded branch comparison
Branch flush
PC redirect
Branch-target fetch
Self-checking regression tests
Final mixed-program verification
```

The supported instruction subset is:

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

The processor is not a complete RV32I implementation.

The final regression suite passed all 8 key tests successfully.