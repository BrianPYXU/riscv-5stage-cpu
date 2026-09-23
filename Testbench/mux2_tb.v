`timescale 1ns/1ps

module mux2_tb;

reg [31:0] a;
reg  [31:0] b;
reg sel;

wire [31:0] y;

mux2 uut(
    .a(a),
    .b(b),
    .sel(sel),
    .y(y)
);
initial begin
    $dumpfile("mux2.vcd");
    $dumpvars(0,mux2_tb);
    a=32'd10;
    b=32'd20;
    sel=0;

    #10;
    sel=1;
    #10;
    $finish;
end

endmodule