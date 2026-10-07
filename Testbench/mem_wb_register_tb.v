`timescale 1ns/1ps
module mem_wb_register_tb;

reg clk;
reg reset;
reg flush;
reg stall;

reg [31:0] alu_result_in;
reg [31:0] memory_data_in;
reg [4:0] rd_in;
reg reg_write_in;
reg mem_to_reg_in;

wire [31:0] alu_result_out;
wire [31:0] memory_data_out;
wire [4:0] rd_out;
wire reg_write_out;
wire mem_to_reg_out;

mem_wb_register uut(
    .clk(clk),
    .reset(reset),
    .stall(stall),
    .flush(flush),
    
    .alu_result_in(alu_result_in),
    .memory_data_in(memory_data_in),
    .rd_in(rd_in),
    .reg_write_in(reg_write_in),
    .mem_to_reg_in(mem_to_reg_in),

    .alu_result_out(alu_result_out),
    .memory_data_out(memory_data_out),
    .rd_out(rd_out),
    .reg_write_out(reg_write_out),
    .mem_to_reg_out(mem_to_reg_out)
);

always #5 clk = ~clk;

initial begin
    $dumpfile("mem_wb_register.vcd");
    $dumpvars(0,mem_wb_register_tb);
    clk = 0;
    reset = 1;
    flush = 0;
    stall = 0;

    alu_result_in = 32'd10;
    memory_data_in = 32'd20;
    rd_in = 5'd1;
    reg_write_in = 1'b0;
    mem_to_reg_in = 1'b0;

    #10;
    reset = 0;

    #10;
    flush = 1;

    #10;
    stall = 1;

    #10;
    flush =0;
    alu_result_in = 32'd30;
    memory_data_in = 32'd40;
    rd_in = 5'd4;
    reg_write_in = 1'b1;
    mem_to_reg_in = 1'b1;

    #10;
    stall = 0;

    #10;
    $finish;
end

endmodule