# Day 18 - Final Mixed Verification and Hazard Refinement

> Historical development record: the original sections below describe the work at this stage. The postscript records the later write-back bypass and final-test extension.

## Goal

Complete a final mixed-program pipeline test and refine load-use hazard detection to avoid unnecessary stalls.

## Final Mixed Program

A larger program was created to verify multiple processor features together.

The program includes:

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
```

It also exercises:

```text
EX/MEM forwarding
MEM/WB forwarding
Store-data forwarding
Load-use stall
Data memory
Branch flush
PC redirect
Branch target fetch
Write-back
```

Final expected values:

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

The self-checking test reported:

```text
ALL FINAL MIXED PIPELINE TESTS PASSED
```

with:

```text
errors = 0
```

## Hazard Detection Refinement

The original load-use hazard detector compared `rd_ex` with both `rs1_id` and `rs2_id`.

This could cause unnecessary stalls for instructions such as ADDI and LW, which do not actually use `rs2`.

Two new decoder signals were added:

```text
uses_rs1
uses_rs2
```

The hazard detector now only checks source registers that are actually used by the current instruction.

Example:

```text
rd_ex = 5
rs2_id = 5
uses_rs2 = 0
```

Old behavior:

```text
stall = 1
```

New behavior:

```text
stall = 0
```

True load-use dependencies still stall normally.

## Regression Verification

After the modification, the following tests passed:

```text
hazard_detection_unit_tb
pipeline_load_use_tb
pipeline_final_tb
```

This confirms:

```text
True hazards still stall correctly
False rs2 hazards no longer stall
The listed directed tests produced their expected results
```

## Current Status

The main processor implementation is now functionally complete for the current project scope.

Implemented features include:

```text
5-stage IF/ID/EX/MEM/WB pipeline
Instruction and data memory
Forwarding
Store-data forwarding
Load-use hazard handling
Source-aware hazard detection
BEQ and control-hazard flushing
PC redirect and branch target fetch
Self-checking regression tests
Final mixed-program verification
```

## Next Steps

Remaining work is mainly project cleanup:

1. Update README.
2. Review regression test filenames and structure.
3. Clean up representative GTKWave screenshots.
4. Run one final regression check.
5. Finalize the GitHub repository for portfolio use.

## Postscript: write-back bypass and final-test extension

The mixed-program test was later extended to check a same-cycle WB/ID dependency. The register file now bypasses the current write-back value to either read port when a nonzero read address matches an enabled write address. Reads of `x0` remain zero.

Four instructions were appended to the existing [pipeline_final_tb.v](../../Testbench/pipeline_final_tb.v):

```assembly
addi x13, x0, 7
addi x14, x0, 1
addi x15, x0, 2
add  x16, x13, x13
```

The independent instructions place the final ADD's ID stage in the same cycle as the first ADDI's WB stage. Both source operands must receive 7, so the additional expected values are:

```text
x13 = 7
x14 = 1
x15 = 2
x16 = 14
```

The earlier expected values for x1–x12 and memory[0] remain unchanged. The test initializes x13–x16, waits 300 ns after reset release, and uses `!==` for expected-value comparisons so unknown values also increment `errors`. The existing `errors` counter determines the printed PASS/FAIL message.

This extends the existing final testbench; the core suite still contains eight testbenches. The [current README](../../README.md#mixed-program-result) and [updated mixed-program waveform](../waveforms/pipeline_final_waveform.png) describe this extended version.

The original sections above remain a record of the earlier development stage rather than a claim that all possible instruction sequences have been verified.
