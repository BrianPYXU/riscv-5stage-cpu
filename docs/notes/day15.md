# Day 15 - BEQ, Control Hazards, and Store-Data Forwarding

## Goal

Add BEQ support, resolve control hazards caused by taken branches, and improve the SW datapath with store-data forwarding.

## Implemented

- Added BEQ decode support.
- Added branch control signal.
- Added B-type immediate generation.
- Propagated branch control through ID/EX.
- Propagated branch PC into EX.
- Added branch target calculation.
- Added branch comparison.
- Added branch-taken detection.
- Added PC redirect support.
- Added IF/ID flush on taken branch.
- Added ID/EX flush on taken branch.
- Verified taken and not-taken branch behavior.
- Added store-data forwarding for SW.

## BEQ Decode

BEQ uses:

```text
opcode = 1100011
funct3 = 000
```