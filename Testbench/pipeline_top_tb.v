`timescale 1ns/1ps

module pipeline_top_tb;

reg clk;
reg reset;
reg [31:0] instruction;
wire [31:0] pc_if_value;
wire [31:0] pc_ex_value;
wire [31:0] immediate_ex_value;
wire branch_ex_value;
wire branch_equal_ex_value;
wire branch_taken_ex_value;
wire [31:0] branch_target_ex_value;
wire [31:0] x5_value;
integer errors;
wire [31:0] memory_0_value;

assign memory_0_value = uut.data_mem.memory[0];
assign pc_if_value            = uut.pc_if;
assign pc_ex_value            = uut.pc_ex;
assign immediate_ex_value     = uut.immediate_ex;
assign branch_ex_value        = uut.branch_ex;
assign branch_equal_ex_value  = uut.branch_equal_ex;
assign branch_taken_ex_value  = uut.branch_taken_ex;
assign branch_target_ex_value = uut.branch_target_ex;
assign x5_value = uut.reg_file.registers[5];
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
    instruction = 32'd0;
    errors = 0;
    uut.reg_file.registers[1] = 32'd5;
    uut.reg_file.registers[2] = 32'd0;
    uut.reg_file.registers[5] = 32'd0;
    uut.data_mem.memory[0] = 32'd0;

    #10;
    reset = 0;    
    instruction = 32'b00000000101000000000001010010011;
    
    #10;
    instruction = 32'b00000000010100010010000000100011; 


    #10;
    instruction = 32'd0;

    #50;
    if (x5_value != 32'd10)
        errors = errors + 1;

    if (memory_0_value != 32'd10)
        errors = errors + 1;

    if (errors == 0)
        $display("ALL STORE-DATA FORWARDING TESTS PASSED");
    else
        $display("%0d STORE-DATA FORWARDING TESTS FAILED", errors);
    $finish;
end

endmodule;
