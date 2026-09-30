`timescale 1ns/1ps

module alu_tb;

reg [31:0] a;
reg [31:0] b;
reg [3:0] control;

wire [31:0] result;

alu uut(
    .a(a),
    .b(b),
    .control(control),
    .result(result)
);

initial begin
    $dumpfile("alu.vcd");
    $dumpvars(0,alu_tb);
    a=32'd10;
    b=32'd20;
    control=4'b0000;

    #10;
    control=4'b0001;

    #10;
    control=4'b0010;

    #10;
    control=4'b0011;

    #10;
    $finish;
end

endmodule