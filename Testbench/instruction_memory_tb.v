`timescale 1ns/1ps

module instruction_memory_tb;

reg [31:0] address;
wire [31:0] instruction;
integer errors;


instruction_memory uut(
    .address(address),
    .instruction(instruction)
);

initial begin
    $dumpfile("instruction_memory.vcd");
    $dumpvars(0,instruction_memory_tb);
    uut.memory[0] = 32'h11111111;
    uut.memory[1] = 32'h22222222;
    uut.memory[2] = 32'h33333333;
    errors = 0;
    address = 32'd0;

    #10;
    if (instruction != 32'h11111111)
        errors = errors + 1;
    address = 32'd4;

    #10;
    if (instruction != 32'h22222222)
        errors = errors + 1;
    address = 32'd8;

    #10;
    if (instruction != 32'h33333333)
        errors = errors + 1;
    if (errors == 0)
        $display("ALL INSTRUCTION MEMORY TESTS PASSED");
    else
        $display("%0d INSTRUCTION MEMORY TESTS FAILED", errors);
    $finish;

end
endmodule