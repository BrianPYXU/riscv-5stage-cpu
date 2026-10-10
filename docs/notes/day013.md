## Day 13 – Forwarding Unit

### Implemented
- Created a combinational `forwarding_unit`
- Added forwarding control for both ALU operands
- Supported forwarding from:
  - EX/MEM
  - MEM/WB
- Added priority:
  - EX/MEM > MEM/WB
- Excluded register `x0` from forwarding

### Verification
Tested:
- No forwarding
- EX/MEM → operand A
- MEM/WB → operand A
- EX/MEM → operand B
- MEM/WB → operand B
- EX/MEM priority over MEM/WB
- x0 exclusion

The self-checking testbench passed all cases.

### Next
- Integrate the forwarding unit into `pipeline_top`
- Add forwarding MUX paths
- Test dependent instructions