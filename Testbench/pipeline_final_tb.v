`timescale 1ns/1ps

module pipeline_final_tb;

reg clk;
reg reset;
integer errors;


wire [31:0] x1_value;
wire [31:0] x2_value;
wire [31:0] x3_value;
wire [31:0] x4_value;
wire [31:0] x5_value;
wire [31:0] x6_value;
wire [31:0] x7_value;
wire [31:0] x8_value;
wire [31:0] x9_value;
wire [31:0] x10_value;
wire [31:0] x11_value;
wire [31:0] x12_value;

wire [31:0] mem0_value;


assign x1_value = uut.reg_file.registers[1];
assign x2_value = uut.reg_file.registers[2];
assign x3_value = uut.reg_file.registers[3];
assign x4_value = uut.reg_file.registers[4];
assign x5_value = uut.reg_file.registers[5];
assign x6_value = uut.reg_file.registers[6];
assign x7_value = uut.reg_file.registers[7];
assign x8_value = uut.reg_file.registers[8];
assign x9_value = uut.reg_file.registers[9];
assign x10_value = uut.reg_file.registers[10];
assign x11_value = uut.reg_file.registers[11];
assign x12_value = uut.reg_file.registers[12];

assign mem0_value = uut.data_mem.memory[0];


pipeline_top uut(
    .clk(clk),
    .reset(reset)
);

always #5 clk = ~clk;

initial begin
    $dumpfile("pipeline_final.vcd");
    $dumpvars(0,pipeline_final_tb);
    clk = 0;
    reset = 1;
    errors = 0;
    uut.reg_file.registers[1]  = 32'd0;
    uut.reg_file.registers[2]  = 32'd0;
    uut.reg_file.registers[3]  = 32'd0;
    uut.reg_file.registers[4]  = 32'd0;
    uut.reg_file.registers[5]  = 32'd0;
    uut.reg_file.registers[6]  = 32'd0;
    uut.reg_file.registers[7]  = 32'd0;
    uut.reg_file.registers[8]  = 32'd0;
    uut.reg_file.registers[9]  = 32'd0;
    uut.reg_file.registers[10]  = 32'd0;
    uut.reg_file.registers[11]  = 32'd0;
    uut.reg_file.registers[12]  = 32'd0;

    uut.data_mem.memory[0] = 32'd0;

    uut.inst_mem.memory[0] = 32'b00000000110000000000000010010011; 
    uut.inst_mem.memory[1] = 32'b00000000101000000000000100010011;
    uut.inst_mem.memory[2] = 32'b00000000001000001000000110110011;
    uut.inst_mem.memory[3] = 32'b00000000001100000010000000100011;
    uut.inst_mem.memory[4] = 32'b00000000000000000010010010000011;
    uut.inst_mem.memory[5] = 32'b00000000001001001000010100110011; 
    uut.inst_mem.memory[6] = 32'b01000000001000001000001000110011;
    uut.inst_mem.memory[7] = 32'b00000000001000001111001010110011;
    uut.inst_mem.memory[8] = 32'b00000000001000001110001100110011;
    uut.inst_mem.memory[9] = 32'b00000000001000001100001110110011;
    uut.inst_mem.memory[10] = 32'b00000000000100010010010000110011; 
    uut.inst_mem.memory[11] = 32'b00000000001101001000010001100011;
    uut.inst_mem.memory[12] = 32'b00000110001100000000010110010011;
    uut.inst_mem.memory[13] = 32'b00000010101000000000011000010011;


    #10;
    reset = 0;

    #200;
    if (x1_value != 32'd12)
        errors = errors + 1;
    if (x2_value != 32'd10)
        errors = errors + 1;
    if (x3_value != 32'd22)
        errors = errors + 1;
    if (x4_value != 32'd2)
        errors = errors + 1;
    if (x5_value != 32'd8)
        errors = errors + 1;
    if (x6_value != 32'd14)
        errors = errors + 1;
    if (x7_value != 32'd6)
        errors = errors + 1;
    if (x8_value != 32'd1)
        errors = errors + 1;
    if (x9_value != 32'd22)
        errors = errors + 1;
    if (x10_value != 32'd32)
        errors = errors + 1;
    if (x11_value != 32'd0)
        errors = errors + 1;
    if (x12_value != 32'd42)
        errors = errors + 1;
    if (mem0_value != 32'd22)
        errors = errors + 1;


    if (!errors)
        $display("ALL FINAL MIXED PIPELINE TESTS PASSED");
    else
        $display("%0d FINAL MIXED PIPELINE TESTS FAILED", errors);
    $finish;
end

endmodule;
