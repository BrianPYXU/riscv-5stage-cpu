`timescale 1ns/1ps

module pipeline_top_tb;

reg clk;
reg reset;
reg [31:0] instruction;
wire [31:0] x2_value;
wire [31:0] x3_value;
wire [31:0] x6_value;
integer errors;

assign x2_value = uut.reg_file.registers[2];
assign x3_value = uut.reg_file.registers[3];
assign x6_value = uut.reg_file.registers[6];

pipeline_top uut(
    .clk(clk),
    .reset(reset),
    .instruction(instruction)
);

always #5 clk = ~clk;

initial begin
    $dumpfile("pipeline_top.vcd");
    $dumpvars(0,pipeline_top_tb);
    clk = 0;
    reset = 1;
    errors = 0;
    instruction = 32'd0;
    uut.reg_file.registers[1]=32'd10;
    uut.reg_file.registers[4]=32'd20;
    uut.reg_file.registers[5]=32'd30;
    uut.reg_file.registers[7]=32'd40;
    uut.reg_file.registers[8]=32'd15;
    
    
    #10;
    reset = 0;
    instruction = 32'b00000000100000001000000100010011;

    #10;
    instruction = 32'b00000000010100100000000110110011;

    #10;
    instruction = 32'b01000000100000111000001100110011;

    #10;
    instruction = 32'd0;

    #40;
    if (uut.reg_file.registers[2] == 32'd18) 
        $display("PASS: x2 = 18");
    else begin
        $display("FAIL: x2 = %d", uut.reg_file.registers[2]); 
        errors = errors + 1;
    end
    if (uut.reg_file.registers[3] == 32'd50) 
        $display("PASS: x3 = 50");
    else begin
        $display("FAIL: x3 = %d", uut.reg_file.registers[3]);
        errors = errors + 1;
    end
    if (uut.reg_file.registers[6] == 32'd25) 
        $display("PASS: x6 = 25");
        
    else begin
        $display("FAIL: x6 = %d", uut.reg_file.registers[6]);
        errors = errors + 1;
    end
    if (errors == 0)
        $display("ALL TEST PASSED");
    else 
        $display("%0d TESTS FAILED" , errors);    
    
    $finish;
end

endmodule;
