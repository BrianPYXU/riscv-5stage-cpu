`timescale 1ns/1ps

module pipeline_load_use_tb;

reg clk;
reg reset;
integer errors;

wire [31:0] x5_value;
wire [31:0] x6_value;
wire hazard_stall_value;

assign x5_value = uut.reg_file.registers[5];
assign x6_value = uut.reg_file.registers[6];
assign hazard_stall_value = uut.hazard_stall;

pipeline_top uut(
    .clk(clk),
    .reset(reset)
);

always #5 clk = ~clk;

initial begin
    $dumpfile("pipeline_load_use.vcd");
    $dumpvars(0,pipeline_load_use_tb);
    clk = 0;
    reset = 1;
    errors = 0;
    uut.reg_file.registers[2] = 32'd0;
    uut.reg_file.registers[3] = 32'd20;
    uut.reg_file.registers[5] = 32'd0;
    uut.reg_file.registers[6] = 32'd0;
    uut.data_mem.memory[0] = 32'd12;
    uut.inst_mem.memory[0] = 32'b00000000000000010010001010000011;
    uut.inst_mem.memory[1] = 32'b00000000001100101000001100110011;


    #10;
    reset = 0;

    #90;
    if (x5_value != 32'd12)
        errors = errors + 1;

    if (x6_value != 32'd32)
        errors = errors + 1;

    if (!errors)
        $display("ALL LOAD-USE PIPELINE TESTS PASSED");
    else
        $display("%0d LOAD-USE PIPELINE TESTS FAILED", errors);
    $finish;
end

endmodule;
