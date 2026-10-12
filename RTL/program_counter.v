module program_counter(
    input clk,
    input reset,
    input stall,
    output reg [31:0] pc
);
always @(posedge clk)
begin
    if (reset)
        pc <= 32'd0;
    else if (stall)
        pc <= pc;
    else
        pc <= pc+32'd4;
end
endmodule