`timescale 1ns/1ps
module ex_mem_register_tb;

reg clk;
reg reset; 
reg stall;
reg flush;

reg [31:0] alu_result_in;
reg [31:0] store_data_in;
reg [4:0] rd_in;
reg reg_write_in;
reg mem_read_in;
reg mem_write_in;
reg mem_to_reg_in;

wire [31:0] alu_result_out;
wire [31:0] store_data_out;
wire [4:0] rd_out;
wire reg_write_out;
wire mem_read_out;
wire mem_write_out;
wire mem_to_reg_out;

ex_mem_register uut(
    .clk(clk),
    .reset(reset),
    .stall(stall),
    .flush(flush),

    .alu_result_in(alu_result_in),
    .store_data_in(store_data_in),
    .rd_in(rd_in),
    .reg_write_in(reg_write_in),
    .mem_read_in(mem_read_in),
    .mem_write_in(mem_write_in),
    .mem_to_reg_in(mem_to_reg_in),

    .alu_result_out(alu_result_out),
    .store_data_out(store_data_out),
    .rd_out(rd_out),
    .reg_write_out(reg_write_out),
    .mem_read_out(mem_read_out),
    .mem_write_out(mem_write_out),
    .mem_to_reg_out(mem_to_reg_out)
);

always #5 clk = ~clk;

initial begin
    $dumpfile("ex_mem_register.vcd");
    $dumpvars(0,ex_mem_register_tb);
    clk = 0;
    reset = 1;
    stall = 0;
    flush = 0;

    alu_result_in = 32'd10;
    store_data_in = 32'd20;
    rd_in = 5'd1;
    reg_write_in = 0;
    mem_read_in = 0;
    mem_write_in = 0;
    mem_to_reg_in = 0;

    #10;
    reset = 0;

    #10;
    flush = 1;

    #10;
    stall = 1;

    #10;
    flush = 0;
    alu_result_in = 32'd30;
    store_data_in = 32'd40;
    rd_in = 5'd5;
    reg_write_in = 1;
    mem_read_in = 1;
    mem_write_in = 1;
    mem_to_reg_in = 1;

    #10;
    stall = 0;

    #10;
    $finish;

end
endmodule