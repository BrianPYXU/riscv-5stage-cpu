module immediate_generator(
    input [31:0] instruction,
    output reg [31:0] immediate
);
always @(*)begin
    immediate=32'd0;

    if(instruction[6:0] == 7'b0010011)
        immediate={{20{instruction[31]}},instruction[31:20]};
    else if(instruction[6:0] == 7'b0100011)
        immediate={{20{instruction[31]}},instruction[31:25],instruction[11:7]};
    
end
endmodule