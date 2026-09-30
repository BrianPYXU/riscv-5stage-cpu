`timescale 1ns/1ps
module datapath_top_tb;
reg clk;
reg write_enable;
reg [31:0] instruction;
wire [31:0] alu_result;
wire [31:0] x5_value;
wire [31:0] x6_value;
wire [31:0] x7_value;
wire [31:0] x8_value;
wire alu_src_value;

assign x5_value = uut.regfile.registers[5];
assign x6_value = uut.regfile.registers[6];
assign x7_value = uut.regfile.registers[7];
assign x8_value = uut.regfile.registers[8];
assign alu_src_value = uut.alu_src;
datapath_top uut(
    .clk(clk),
    .write_enable(write_enable),
    .instruction(instruction),
    .alu_result(alu_result)
);

always #5 clk=~clk;

initial begin
    $dumpfile("datapath_top.vcd");
    $dumpvars(0,datapath_top_tb);
    clk=0;
    write_enable=1;
    instruction=32'd0;
    uut.regfile.registers[2]=32'd10;
    uut.regfile.registers[3]=32'd20;

    instruction = 32'b00000000001100010000001010110011;
    
    #10;
    instruction = 32'b01000000001000101000001100110011;
    #10;
    instruction = 32'b00000000010100110000001110010011; 
    #10;
    instruction = 32'b11111111110000111000010000010011;
    #10;
    $finish;
end
endmodule