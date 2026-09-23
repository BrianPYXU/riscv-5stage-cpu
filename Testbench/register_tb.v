`timescale 1ns/1ps

module register_tb;

reg clk;
reg reset;
reg[31:0]d;

wire[31:0] q;


register uut(
    .clk(clk),
    .reset(reset),
    .d(d),
    .q(q)
);

initial begin
    $dumpfile("register.vcd");
    $dumpvars(0,register_tb);
    clk =0;
    reset=1;
    d=32'd0;

    #10;
    reset=0;

    #2;
    d=32'd10;

    #10;
    d=32'd20;

    #10;
    $finish;
end
always #5 clk=~clk;
endmodule