# 5-Stage Pipelined RISC-V CPU

A RISC-V processor project implemented in Verilog, developed step by step from basic RTL components toward a 5-stage pipelined CPU.

## Current Progress

### RTL Fundamentals
- [x] 32-bit Register
- [x] 32-bit 2-to-1 Multiplexer
- [x] Basic 32-bit ALU
- [x] Testbench simulation with Icarus Verilog
- [x] Waveform verification with GTKWave

### Processor
- [x] Register File
- [x] Program Counter
- [x] Instruction Decoder
- [x] Immediate Generator
- [x] Datapath Integration
- [x] IF/ID Pipeline Register
- [x] ID/EX Pipeline Register
- [x] EX/MEM Pipeline Register
- [ ] MEM/WB Pipeline Register
- [ ] Hazard Detection
- [ ] Data Forwarding

## Project Structure

```text
riscv-5stage-cpu/
├── RTL/          # Verilog RTL modules
├── Testbench/    # Verification testbenches
├── docs/
│   ├── notes/
│   └── waveforms/
└── README.md
```

## Tools

- Verilog
- Icarus Verilog
- GTKWave

## Development Status

🚧 Work in progress — currently building and verifying the fundamental RTL components.