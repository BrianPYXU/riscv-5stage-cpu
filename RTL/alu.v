module alu(
    input wire [31:0] a,
    input wire [31:0] b,
    input wire [2:0] control,

    output reg [31:0] result
);

always @(*) begin 
    case(control)
        3'b000:result =a+b;
        3'b001:result =a-b;
        3'b010:result=a&b;
        3'b011:result=a|b;
        default:result=32'd0;
    endcase
end
endmodule