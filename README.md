# 5-Stage Pipelined RISC-V CPU (Work in Progress)

A RISC-V processor project implemented in Verilog, developed step by step from basic RTL components toward a 5-stage pipelined CPU.

The current implementation includes a basic pre-pipeline datapath for ADD, SUB, and ADDI, plus four standalone pipeline registers. The registers have not yet been integrated into a complete 5-stage CPU. Full RV32I support and end-to-end CPU verification remain future work.

## Current Instruction Support

The current pre-pipeline datapath supports:

| Instruction | Status |
| --- | --- |
| ADD | Implemented |
| SUB | Implemented |
| ADDI | Implemented |

These instructions are implemented in the basic datapath and exercised by its component-level testbench. Instructions are supplied directly by the testbench, and register write enable is externally controlled.

Additional RV32I instructions will be added as the pipeline, memory stage, branch logic, hazard detection, and forwarding logic are integrated. The immediate generator supports ADDI I-type and store S-type immediate extraction, but load/store execution and an integrated memory stage are not implemented.

## Current Progress

Completed items below refer to individual modules and basic datapath integration. Pipeline-register stall/flush inputs are implemented; automatic hazard detection and CPU-wide stall/flush control remain pending.

### RTL Fundamentals

- [x] 32-bit Register
- [x] 32-bit 2-to-1 Multiplexer
- [x] Basic 32-bit ALU
- [x] Component testbench simulation with Icarus Verilog
- [x] Manual waveform inspection with GTKWave

### Processor

- [x] Register File
- [x] Program Counter (standalone module)
- [x] Instruction Decoder (ADD, SUB, ADDI)
- [x] Immediate Generator (ADDI I-type and store S-type immediates)
- [x] Basic Datapath Integration (ADD, SUB, ADDI)
- [x] IF/ID Pipeline Register
- [x] ID/EX Pipeline Register
- [x] EX/MEM Pipeline Register
- [x] MEM/WB Pipeline Register
- [ ] Instruction Memory / Fetch Integration
- [ ] Data Memory / Load-Store Integration
- [ ] 5-Stage Pipeline Integration
- [ ] Data Forwarding
- [ ] Hazard Detection / Stall
- [ ] Branch Handling

## Verification Status

Current verification uses component-level stimulus testbenches, Icarus Verilog simulation, and manual GTKWave inspection. Development notes and waveform screenshots are retained under `docs/notes/` and `docs/waveforms/`.

The basic datapath testbench directly initializes internal registers and supplies instructions to exercise ADD, SUB, and ADDI. This is a basic datapath check; a complete CPU executing programs from instruction memory has not yet been verified. Final self-checking testbenches and end-to-end program-based CPU verification are planned below.

## Future Work

- Integrate instruction fetch, all four pipeline registers, and the write-back path into a 5-stage CPU.
- Integrate data memory and extend the supported RV32I instruction subset.
- Add forwarding, hazard detection with stall control, and branch/flush handling.
- Add final self-checking testbenches with automatic expected-result comparisons, explicit PASS/FAIL results, failure exit status, and timeouts.
- Add end-to-end program-based CPU verification: load test programs into instruction memory, let the CPU execute them, and check final architectural register and memory state. Initialize register operands through executed instructions rather than direct writes to the internal register array.
- Include dependent instruction sequences and memory/branch cases as those features are integrated. For example, execute `addi x2, x0, 10`, `addi x3, x0, 20`, `add x5, x2, x3`, and `sub x6, x5, x2`, then automatically check `x5 = 30` and `x6 = 20`.

## Project Structure

```text
riscv-5stage-cpu/
├── RTL/          # Verilog RTL modules
├── Testbench/    # Component stimulus testbenches
├── docs/
│   ├── notes/    # Development notes
│   └── waveforms/ # Waveform screenshots
└── README.md
```

## Tools

- Verilog
- Icarus Verilog
- GTKWave

## Development Status

Work in progress: basic RTL modules, the ADD/SUB/ADDI pre-pipeline datapath, and all four standalone pipeline registers are implemented. Complete 5-stage pipeline integration, memory execution, forwarding, hazard detection, branch handling, and final CPU verification remain pending.
