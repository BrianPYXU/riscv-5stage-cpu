# Day 17 - Logic Instructions and Regression Test Cleanup

## Goal

Expand the supported R-type instruction set and begin organizing pipeline-level verification into permanent regression testbenches.

## Implemented

- Added AND instruction support
- Added OR instruction support
- Added XOR instruction support
- Added SLT instruction support
- Added signed comparison for SLT
- Verified all new logic instructions through the full 5-stage pipeline
- Created a dedicated logic-instruction regression test
- Created a dedicated load-use hazard regression test

---

## AND

AND is an R-type instruction.

Encoding:

```text
opcode = 0110011
funct3 = 111
funct7 = 0000000
```

ALU control:

```text
0010 → AND
```

The decoder generates:

```text
reg_write   = 1
alu_src     = 0
alu_control = 0010
```

Pipeline test:

```assembly
and x3, x1, x2
```

Initial values:

```text
x1 = 12
x2 = 10
```

Binary values:

```text
12 = 1100
10 = 1010
```

Expected:

```text
1100 AND 1010 = 1000
x3 = 8
```

The pipeline produced:

```text
x3 = 8
```

---

## OR

OR is also an R-type instruction.

Encoding:

```text
opcode = 0110011
funct3 = 110
funct7 = 0000000
```

ALU control:

```text
0011 → OR
```

Pipeline test:

```assembly
or x6, x1, x2
```

Using:

```text
x1 = 12
x2 = 10
```

Expected:

```text
1100 OR 1010 = 1110
x6 = 14
```

The pipeline produced:

```text
x6 = 14
```

---

## XOR

XOR required a new ALU operation.

The ALU control mapping was extended with:

```text
0100 → XOR
```

The ALU operation is:

```verilog
result = a ^ b;
```

XOR encoding:

```text
opcode = 0110011
funct3 = 100
funct7 = 0000000
```

The decoder generates:

```text
reg_write   = 1
alu_src     = 0
alu_control = 0100
```

### ALU Verification

One standalone ALU test used:

```text
a = 10
b = 20
```

Expected:

```text
10 XOR 20 = 30
```

The ALU produced:

```text
result = 0x0000001E
```

which is decimal 30.

### Pipeline Verification

Pipeline test:

```assembly
xor x7, x1, x2
```

With:

```text
x1 = 12
x2 = 10
```

Expected:

```text
1100 XOR 1010 = 0110
x7 = 6
```

The pipeline produced:

```text
x7 = 6
```

---

## SLT

SLT performs signed less-than comparison.

ALU control:

```text
0101 → SLT
```

The ALU uses signed comparison:

```verilog
result = ($signed(a) < $signed(b)) ? 32'd1 : 32'd0;
```

This is important because negative values must be interpreted as signed 32-bit numbers.

For example:

```text
-13 < 10
```

must evaluate to:

```text
1
```

If the operands were compared as unsigned values, `-13` would appear as a large positive 32-bit value and the comparison would be incorrect.

SLT encoding:

```text
opcode = 0110011
funct3 = 010
funct7 = 0000000
```

The decoder generates:

```text
reg_write   = 1
alu_src     = 0
alu_control = 0101
```

### ALU Verification

Signed SLT was tested with:

```text
a = -5
b = 3
```

Expected:

```text
-5 < 3 → 1
```

The ALU produced:

```text
result = 1
```

A reverse comparison was also used to confirm signed behavior.

### Pipeline Verification

The pipeline test included:

```assembly
slt x8, x1, x2
```

with:

```text
x1 = 12
x2 = 10
```

Expected:

```text
12 < 10 → 0
```

The pipeline produced:

```text
x8 = 0
```

Signed pipeline behavior was also verified using:

```text
x4 = -13
x2 = 10
```

with:

```assembly
slt x9, x4, x2
```

Expected:

```text
-13 < 10 → 1
```

The final self-check passed successfully.

---

## Logic Pipeline Test

The combined logic instruction test includes:

```assembly
and x3, x1, x2
or  x6, x1, x2
xor x7, x1, x2
slt x8, x1, x2
slt x9, x4, x2
```

Initial values include:

```text
x1 = 12
x2 = 10
x4 = -13
```

Expected results:

```text
x3 = 8
x6 = 14
x7 = 6
x8 = 0
x9 = 1
```

All expected values were verified using automatic checking.

The test reported:

```text
ALL PIPELINE TESTS PASSED
```

---

## Regression Test Cleanup

Earlier pipeline development reused:

```text
pipeline_top_tb.v
```

for multiple integration tests.

This meant older tests were replaced whenever a new test was written.

To improve verification quality, important tests are now being saved as independent regression testbenches.

### Logic Regression Test

The current logic test has been preserved as:

```text
Testbench/pipeline_logic_tb.v
```

It verifies:

```text
AND
OR
XOR
SLT
Signed SLT
```

The test can be compiled using:

```bash
iverilog -s pipeline_logic_tb -o pipeline_logic_sim RTL/*.v Testbench/pipeline_logic_tb.v
```

and executed with:

```bash
vvp pipeline_logic_sim
```

Expected output:

```text
ALL PIPELINE TESTS PASSED
```

---

## Load-Use Regression Test

The previously verified load-use test was also restored as a dedicated testbench:

```text
Testbench/pipeline_load_use_tb.v
```

Test sequence:

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

This test sequence exercises the following design mechanisms:

```text
LW execution
Load-use hazard detection
PC stall
IF/ID stall
ID/EX bubble insertion
Loaded-data forwarding
Final architectural state
```

The saved testbench automatically checks the final values `x5 = 12` and `x6 = 32`. It does not separately assert the exact stall length or each pipeline register's per-cycle hold/flush behavior; those signals can be inspected in the waveform.

The self-checking test reported:

```text
ALL LOAD-USE PIPELINE TESTS PASSED
```

---

## Current Instruction Support

The processor now supports:

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

New instructions completed today:

```text
AND
OR
XOR
SLT
```

---

## Verification Status

Completed today:

```text
AND decoder verification
AND pipeline verification

OR decoder verification
OR pipeline verification

XOR ALU verification
XOR decoder verification
XOR pipeline verification

SLT signed ALU verification
SLT decoder verification
SLT pipeline verification

pipeline_logic_tb regression test
pipeline_load_use_tb regression test
```

---

## Remaining Regression Tests

The following previously verified behaviors still need dedicated permanent testbenches:

```text
Store-data forwarding
BEQ taken
BEQ not taken
Branch target fetch
```

Planned files include:

```text
pipeline_store_forwarding_tb.v
pipeline_branch_tb.v
pipeline_branch_fetch_tb.v
```

---

## Next Steps

The next development session will focus on verification cleanup rather than immediately adding more instructions.

Planned next steps:

1. Create `pipeline_store_forwarding_tb.v`
2. Preserve branch taken/not-taken verification
3. Preserve branch-target fetch verification
4. Build a larger mixed-instruction test program
5. Verify arithmetic, logic, memory, hazards, forwarding, and branch behavior together
6. Improve hazard detection to avoid unnecessary stalls for instructions that do not use `rs2`
7. Prepare final representative waveforms and documentation

## Status

The processor now supports a broader set of R-type logic operations and has begun transitioning from feature development toward reusable regression testing and final program-level verification.