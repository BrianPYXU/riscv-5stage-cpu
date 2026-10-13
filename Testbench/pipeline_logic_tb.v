`timescale 1ns/1ps

module pipeline_logic_tb;

reg clk;
reg reset;
integer errors;

wire [31:0] x3_value;
wire [31:0] x6_value;
wire [31:0] x7_value;
wire [31:0] x8_value;
wire [31:0] x9_value;

assign x3_value = uut.reg_file.registers[3];
assign x6_value = uut.reg_file.registers[6];
assign x7_value = uut.reg_file.registers[7];
assign x8_value = uut.reg_file.registers[8];
assign x9_value = uut.reg_file.registers[9];

pipeline_top uut(
    .clk(clk),
    .reset(reset)
);

always #5 clk = ~clk;

initial begin
    $dumpfile("pipeline_logic.vcd");
    $dumpvars(0,pipeline_logic_tb);
    clk = 0;
    reset = 1;
    errors = 0;
    uut.reg_file.registers[1] = 32'd12;
    uut.reg_file.registers[2] = 32'd10;
    uut.reg_file.registers[3] = 32'd0;    
    uut.reg_file.registers[4] = -32'sd13;
    uut.reg_file.registers[5] = 32'd0;
    uut.reg_file.registers[6] = 32'd0;
    uut.inst_mem.memory[0] = 32'b00000000001000001111000110110011; 
    uut.inst_mem.memory[1] = 32'b00000000001000001110001100110011;
    uut.inst_mem.memory[2] = 32'b00000000001000001100001110110011;
    uut.inst_mem.memory[3] = 32'b00000000001000001010010000110011;
    uut.inst_mem.memory[4] = 32'b00000000001000100010010010110011;


    #10;
    reset = 0;

    #90;
    if (x3_value != 32'd8)
        errors = errors + 1;
    if (x6_value != 32'd14)
        errors = errors + 1;
    if (x7_value != 32'd6)
        errors = errors + 1;
    if (x8_value != 32'd0)
        errors = errors + 1;
    if (x9_value != 1)
        errors = errors + 1;
    if (!errors)
        $display("ALL PIPELINE TESTS PASSED");
    else
        $display("%0d PIPELINE TESTS FAILED", errors);
    $finish;
end

endmodule;
