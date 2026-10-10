`timescale 1ns/1ps

module pipeline_top_tb;

reg clk;
reg reset;
reg [31:0] instruction;
wire [31:0] x2_value;
wire [31:0] x3_value;
wire [31:0] x5_value;
wire [31:0] x6_value;
wire [31:0] x7_value;
wire [31:0] x8_value;
wire [31:0] x9_value;
wire [31:0] x10_value;
wire [31:0] x11_value;
wire [31:0] x12_value;
wire [31:0] x13_value;
wire [31:0] x14_value;
wire [31:0] x15_value;
integer errors;

assign x2_value = uut.reg_file.registers[2];
assign x3_value = uut.reg_file.registers[3];
assign x5_value = uut.reg_file.registers[5];
assign x6_value = uut.reg_file.registers[6];
assign x7_value = uut.reg_file.registers[7];
assign x8_value = uut.reg_file.registers[8];
assign x9_value = uut.reg_file.registers[9];
assign x10_value = uut.reg_file.registers[10];
assign x11_value = uut.reg_file.registers[11];
assign x12_value = uut.reg_file.registers[12];
assign x13_value = uut.reg_file.registers[13];
assign x14_value = uut.reg_file.registers[14];
assign x15_value = uut.reg_file.registers[15];

pipeline_top uut(
    .clk(clk),
    .reset(reset),
    .instruction(instruction)
);

always #5 clk = ~clk;

initial begin
    $dumpfile("pipeline_top.vcd");
    $dumpvars(0,pipeline_top_tb);
    clk = 0;
    reset = 1;
    errors = 0;
    instruction = 32'd0;
    uut.reg_file.registers[4]=32'd20;

    #10;
    reset = 0;
    instruction = 32'b00000000101000000000000100010011; // addi x2,x0,10

    #10;
    instruction = 32'b00000000010000010000000110110011; // add x3,x2,x4

    #10;
    instruction = 32'b00000000110000000000001010010011; // addi x5,x0,12

    #10;
    instruction = 32'b00000000000100000000010010010011; // addi x9,x0,1

    #10;
    instruction = 32'b00000000010000101000001100110011; // add x6,x5,x4

    #10;
    instruction = 32'b00000000011100000000001110010011; // addi x7,x0,7

    #10;
    instruction = 32'b00000000011100100000010000110011; // add x8,x4,x7

    #10;
    instruction = 32'b00000000100100000000010100010011; // addi x10,x0,9

    #10;
    instruction = 32'b00000000000100000000010110010011; // addi x11,x0,1

    #10;
    instruction = 32'b00000000101000100000011000110011; // add x12,x4,x10

    #10;
    instruction = 32'b00000000010100000000011010010011; // addi x13,x0,5

    #10;
    instruction = 32'b00000000011100000000011010010011; // addi x13,x0,7

    #10;
    instruction = 32'b00000000010001101000011100110011; // add x14,x13,x4

    #10;
    instruction = 32'b00000000010000100000011110110011; // add x15,x4,x4

    #10;
    instruction = 32'd0;

    #50;
    if (x2_value != 32'd10)
        errors = errors + 1;
    if (x3_value != 32'd30)
        errors = errors + 1;
    if (x5_value != 32'd12)
        errors = errors + 1;
    if (x6_value != 32'd32)
        errors = errors + 1;
    if (x7_value != 32'd7)
        errors = errors + 1;
    if (x8_value != 32'd27)
        errors = errors + 1;
    if (x9_value != 32'd1)
        errors = errors + 1;
    if (x10_value != 32'd9)
        errors = errors + 1;
    if (x11_value != 32'd1)
        errors = errors + 1;
    if (x12_value != 32'd29)
        errors = errors + 1;
    if (x13_value != 32'd7)
        errors = errors + 1;
    if (x14_value != 32'd27)
        errors = errors + 1;
    if (x15_value != 32'd40)
        errors = errors + 1;
    if (errors == 0)
        $display("ALL FORWARDING TESTS PASSED");
    else
        $display("%0d FORWARDING TESTS FAILED", errors);
    $finish;
end

endmodule;
