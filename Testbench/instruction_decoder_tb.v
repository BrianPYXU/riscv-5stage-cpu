`timescale 1ns/1ps
module instruction_decoder_tb;
reg [31:0] instruction;
wire [6:0] opcode;
wire [4:0] rd;
wire [2:0] funct3;
wire [4:0] rs1;
wire [4:0] rs2;
wire [6:0] funct7;
wire [3:0] alu_control;
instruction_decoder uut(
    .instruction(instruction),
    .opcode(opcode),
    .rd(rd),
    .funct3(funct3),
    .rs1(rs1),
    .rs2(rs2),
    .funct7(funct7),
    .alu_control(alu_control)
);
initial begin
    $dumpfile("instruction_decoder.vcd");
    $dumpvars(0,instruction_decoder_tb);
    instruction = 32'b00000000001100010000001010110011;
    
    #10;
    instruction = 32'b01000000011100110000010100110011;

    #10;
    $finish;
end

endmodule