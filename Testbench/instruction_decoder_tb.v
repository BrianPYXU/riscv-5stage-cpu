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
wire reg_write;
wire mem_read;
wire mem_write;
wire mem_to_reg;
wire alu_src;

instruction_decoder uut(
    .instruction(instruction),
    .opcode(opcode),
    .rd(rd),
    .funct3(funct3),
    .rs1(rs1),
    .rs2(rs2),
    .funct7(funct7),
    .alu_control(alu_control),
    .reg_write(reg_write),
    .mem_read(mem_read),
    .mem_write(mem_write),
    .mem_to_reg(mem_to_reg),
    .alu_src(alu_src)
);

initial begin
    $dumpfile("instruction_decoder.vcd");
    $dumpvars(0,instruction_decoder_tb);
    instruction = 32'b00000000001100010000001010110011;
    
    #1;
    $display("ADD: reg_write=%b mem_read=%b mem_write=%b mem_to_reg=%b alu_src=%b",
            reg_write, mem_read, mem_write, mem_to_reg, alu_src);
    
    #10;
    instruction = 32'b01000000011100110000010100110011;
    
    #1;    
    $display("SUB: reg_write=%b mem_read=%b mem_write=%b mem_to_reg=%b alu_src=%b",
            reg_write, mem_read, mem_write, mem_to_reg, alu_src);
    
    #10;
    instruction = 32'b00000000001100010000001110010011;

    #1;    
    $display("ADDI: reg_write=%b mem_read=%b mem_write=%b mem_to_reg=%b alu_src=%b",
            reg_write, mem_read, mem_write, mem_to_reg, alu_src);

    #10;
    instruction = 32'd0;

    #1;    
    $display("UNSUPPORTED: reg_write=%b mem_read=%b mem_write=%b mem_to_reg=%b alu_src=%b",
            reg_write, mem_read, mem_write, mem_to_reg, alu_src);
    
    #10;
    $finish;


end
endmodule