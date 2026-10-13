module program_counter(
    input clk,
    input reset,
    input stall,
    input branch_taken,
    input [31:0] branch_target,
    output reg [31:0] pc
);
always @(posedge clk)
begin
    if (reset)
        pc <= 32'd0;
    else if (branch_taken)
        pc <= branch_target;
    else if (stall)
        pc <= pc;
    else
        pc <= pc+32'd4;
end
endmodule