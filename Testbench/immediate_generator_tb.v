`timescale 1ns/1ps
module immediate_generator_tb;
reg [31:0] instruction;
wire [31:0] immediate;
immediate_generator uut(
    .instruction(instruction),
    .immediate(immediate)
);
initial begin
    $dumpfile("immediate_generator.vcd");
    $dumpvars(0,immediate_generator_tb);

    instruction=32'b00000000101000010000001010010011;
    #10;
    instruction=32'b11111111110000010000001010010011;
    #10;
    instruction=32'b00000000010100010010010000100011;
    #10;
    $finish;
end
endmodule