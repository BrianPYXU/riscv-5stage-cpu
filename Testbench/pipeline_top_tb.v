`timescale 1ns/1ps

module pipeline_top_tb;

reg clk;
reg reset;
integer errors;

wire [31:0] x5_value;
wire [31:0] x6_value;


assign x5_value = uut.reg_file.registers[5];
assign x6_value = uut.reg_file.registers[6];

pipeline_top uut(
    .clk(clk),
    .reset(reset)
);

always #5 clk = ~clk;

initial begin
    $dumpfile("pipeline_top.vcd");
    $dumpvars(0,pipeline_top_tb);
    clk = 0;
    reset = 1;
    errors = 0;
    uut.reg_file.registers[1] = 32'd5;
    uut.reg_file.registers[2] = 32'd5;
    uut.reg_file.registers[5] = 32'd0;
    uut.reg_file.registers[6] = 32'd0;
    uut.inst_mem.memory[0] = 32'b00000000001000001000010001100011; 
    uut.inst_mem.memory[1] = 32'b00000110001100000000001010010011; 
    uut.inst_mem.memory[2] = 32'b00000010101000000000001100010011; 

    #10;
    reset = 0;

    #90;
    if (x5_value != 32'd0)
        errors = errors + 1;

    if (x6_value != 32'd42)
        errors = errors + 1;

    if (!errors)
        $display("ALL BRANCH FETCH TESTS PASSED");
    else 
        $display("%0d BRANCH FETCH TESTS FAILED", errors);
    $finish;
end

endmodule;
