module mux2(
    input wire [31:0]a,
    input wire [31:0]b,
    input wire sel,

    output wire [31:0]y
);

assign y= sel? a:b;

endmodule