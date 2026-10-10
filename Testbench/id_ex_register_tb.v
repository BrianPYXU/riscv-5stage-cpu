`timescale 1ns/1ps
module id_ex_register_tb;

reg clk;
reg reset;
reg stall;
reg flush;

reg [31:0] read_data1_in;
reg [31:0] read_data2_in;
reg [31:0] immediate_in;
reg [4:0] rd_in;
reg [3:0] alu_control_in;
reg alu_src_in;
reg reg_write_in;
reg mem_read_in;
reg mem_write_in;
reg mem_to_reg_in;

wire [31:0] read_data1_out;
wire [31:0] read_data2_out;
wire [31:0] immediate_out;
wire [4:0] rd_out;
wire [3:0] alu_control_out;
wire alu_src_out;
wire reg_write_out;
wire mem_read_out;
wire mem_write_out;
wire mem_to_reg_out;

id_ex_register uut(
    .clk(clk),
    .reset(reset),
    .stall(stall),
    .flush(flush),

    .read_data1_in(read_data1_in),
    .read_data2_in(read_data2_in),
    .immediate_in(immediate_in),
    .rd_in(rd_in),
    .alu_control_in(alu_control_in),
    .alu_src_in(alu_src_in),
    .reg_write_in(reg_write_in),
    .mem_read_in(mem_read_in),
    .mem_write_in(mem_write_in),
    .mem_to_reg_in(mem_to_reg_in),

    .read_data1_out(read_data1_out),
    .read_data2_out(read_data2_out),
    .immediate_out(immediate_out),
    .rd_out(rd_out),
    .alu_control_out(alu_control_out),
    .alu_src_out(alu_src_out),
    .reg_write_out(reg_write_out),
    .mem_read_out(mem_read_out),
    .mem_write_out(mem_write_out),
    .mem_to_reg_out(mem_to_reg_out)
);

always #5 clk = ~clk;

initial begin
    $dumpfile("id_ex_register.vcd");
    $dumpvars(0,id_ex_register_tb);
    clk = 0;
    reset = 1;
    stall = 0;
    flush = 0;

    read_data1_in = 32'd10;
    read_data2_in =32'd20;
    immediate_in = 32'd30;
    rd_in = 5'd1;
    alu_control_in = 4'b0000;
    alu_src_in = 1'b0;
    reg_write_in = 1'b0;
    mem_read_in = 1'b0;
    mem_write_in = 1'b0;
    mem_to_reg_in = 1'b0;

    #10;
    reset = 0;

    #10;
    flush = 1;
    
    #10
    stall = 1;

    #10;
    flush = 0;
    read_data1_in = 32'd40;
    read_data2_in = 32'd50;
    immediate_in = 32'd60;
    rd_in = 5'd4;
    alu_control_in = 4'b0001;
    alu_src_in = 1'b1;
    reg_write_in = 1'b1;
    mem_read_in = 1'b1;
    mem_write_in = 1'b1;
    mem_to_reg_in = 1'b1;

    #10;
    stall = 0;

    #10;
    $finish;
end
endmodule
