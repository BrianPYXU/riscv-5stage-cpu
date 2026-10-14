`timescale 1ns/1ps

module pipeline_branch_tb;

reg clk;
reg reset;
reg taken_seen;
integer errors;

wire branch_taken_value;

assign branch_taken_value = uut.branch_taken_ex;

pipeline_top uut(
    .clk(clk),
    .reset(reset)
);

always #5 clk = ~clk;
always @(posedge clk) begin
    if (reset)
        taken_seen <= 1'b0;
    else if (branch_taken_value)
        taken_seen <= 1'b1;
end

initial begin
    $dumpfile("pipeline_branch.vcd");
    $dumpvars(0,pipeline_branch_tb);
    clk = 0;
    reset = 1;
    errors = 0;
    uut.reg_file.registers[1] = 32'd5;
    uut.reg_file.registers[2] = 32'd5;
    uut.inst_mem.memory[0] = 32'b00000000001000001000010001100011; 



    #10;
    reset = 0;
       
    #50;
    if (taken_seen != 1'b1) begin
        $display("ERROR: BEQ taken test failed");
        errors = errors + 1;
    end

    #10;
    reset = 1;

    uut.reg_file.registers[1] = 32'd5;
    uut.reg_file.registers[2] = 32'd7;
    uut.inst_mem.memory[0] = 32'b00000000001000001000010001100011;   

    #10;
    reset = 0; 

    #50;
    if (taken_seen != 1'b0) begin
        $display("ERROR: BEQ not-taken test failed");
        errors = errors + 1;
    end

    if (!errors)
        $display("ALL BRANCH PIPELINE TESTS PASSED");
    else
        $display("%0d BRANCH PIPELINE TESTS FAILED", errors);
    $finish;
end

endmodule;
