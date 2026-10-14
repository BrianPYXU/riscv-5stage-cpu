`timescale 1ns/1ps

module pipeline_store_forwarding_tb;

reg clk;
reg reset;
integer errors;

wire [31:0] x5_value;
wire [31:0] mem0_value;

assign x5_value = uut.reg_file.registers[5];
assign mem0_value = uut.data_mem.memory[0];


pipeline_top uut(
    .clk(clk),
    .reset(reset)
);

always #5 clk = ~clk;

initial begin
    $dumpfile("pipeline_store_forwarding.vcd");
    $dumpvars(0,pipeline_store_forwarding_tb);
    clk = 0;
    reset = 1;
    errors = 0;
    uut.reg_file.registers[2] = 32'd0;
    uut.reg_file.registers[5] = 32'd0;
    uut.data_mem.memory[0] = 32'd0;
    uut.inst_mem.memory[0] = 32'b00000000101000000000001010010011; 
    uut.inst_mem.memory[1] = 32'b00000000010100010010000000100011;


    #10;
    reset = 0;

    #90;
    if (x5_value != 32'd10)
        errors = errors + 1;

    if (mem0_value != 32'd10)
        errors = errors + 1;

    if (!errors)
        $display("ALL STORE FORWARDING PIPELINE TESTS PASSED");
    else
        $display("%0d STORE FORWARDING PIPELINE TESTS FAILED", errors);
        
    $finish;
end

endmodule;
