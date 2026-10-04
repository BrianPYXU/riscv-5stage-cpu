`timescale 1ns/1ps
module if_id_register_tb;

reg clk;
reg reset;
reg stall;
reg flush;
reg [31:0] pc_in;
reg [31:0] instruction_in;

wire [31:0] pc_out;
wire [31:0] instruction_out;

if_id_register uut(
    .clk(clk),
    .reset(reset),
    .pc_in(pc_in),
    .instruction_in(instruction_in),
    .stall(stall),
    .flush(flush),
    .pc_out(pc_out),
    .instruction_out(instruction_out)
);

initial begin
    $dumpfile("if_id_register.vcd");
    $dumpvars(0,if_id_register_tb);
    clk = 0;
    flush = 0;
    reset = 1;
    stall = 0;
    pc_in = 32'd4;
    instruction_in =  32'd10; 

    #10;
    reset = 0;
    

    #10;
    stall = 1;
    pc_in = 32'd8;
    instruction_in = 32'd20;

    #10;
    flush = 1;


    #10;
    flush = 0;
    stall = 0;
    pc_in = 32'd12;
    instruction_in = 32'd30;

    #10;
    $finish;
end

always #5 clk = ~clk;

endmodule

