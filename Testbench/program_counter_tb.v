`timescale 1ns/1ps
module program_counter_tb;
reg clk;
reg reset;
wire [31:0] pc;

program_counter uut(
    .clk(clk),
    .reset(reset),
    .pc(pc)
);
initial begin
    $dumpfile("program_counter.vcd");
    $dumpvars(0,program_counter_tb);
    clk=0;
    reset=1;

    #10;
    reset=0;
    #30;
    reset=1;

    #10;
    $finish;
end
always #5 clk=~clk;
endmodule