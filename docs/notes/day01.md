 # Day 01 — RTL Fundamentals

## Core Concepts

### Combinational vs Sequential Logic

**Combinational Logic**
- Output depends on current inputs.
- No clock edge required.
- Examples: MUX, ALU.

**Sequential Logic**
- Can store state.
- Register updates on a clock edge.

```verilog
always @(posedge clk)
    q <= d;
```

---

## Verilog Rules

```text
assign              → usually drives wire
always block        → assigned signal uses reg

Combinational       → =
Clocked Sequential  → <=
```

Important:

```text
reg ≠ automatically a hardware register
```

---

## Modules Implemented

### 32-bit Register
Stores data on `posedge clk`.

### 32-bit 2-to-1 MUX

```verilog
assign y = sel ? b : a;
```

```text
sel = 0 → y = a
sel = 1 → y = b
```

### 32-bit ALU

| Control | Operation |
|---|---|
| `000` | ADD |
| `001` | SUB |
| `010` | AND |
| `011` | OR |

Implemented using:

```verilog
always @(*) begin
    case (alu_control)
        ...
    endcase
end
```

---

## Verification Workflow

```text
RTL + Testbench
      ↓
   iverilog
      ↓
     vvp
      ↓
     VCD
      ↓
   GTKWave
```

Always:

**Predict expected behavior → Simulate → Compare waveform**

---

## Day 1 Result

Implemented and verified:

```text
RTL/
├── register.v
├── mux2.v
└── alu.v

Testbench/
├── register_tb.v
├── mux2_tb.v
└── alu_tb.v
```