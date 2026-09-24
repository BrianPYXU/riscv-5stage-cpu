`timescale 1ns/1ps
module register_file_tb;
reg clk;
reg write_enable;
reg [4:0]read_addr1;
reg [4:0]read_addr2;
reg [4:0] write_addr;
reg [31:0] write_data;

wire [31:0] read_data1;
wire [31:0] read_data2;

register_file uut(
    .clk(clk),
    .write_enable(write_enable),
    .read_addr1(read_addr1),
    .read_addr2(read_addr2),
    .write_addr(write_addr),
    .write_data(write_data),
    .read_data1(read_data1),
    .read_data2(read_data2)
);
initial begin
    $dumpfile("register_file.vcd");
    $dumpvars(0,register_file_tb);
    clk=0;
    write_enable=1;
    write_addr=5'd5;
    write_data=32'd50;
    read_addr1=5'd0;
    read_addr2=5'd0;

    #10;
    read_addr1=5'd5;
    write_addr=5'd7;
    write_data=32'd100;

    #10;
    read_addr1=5'd5;
    read_addr2=5'd7;
    write_enable=0;
    write_addr=5'd5;
    write_data=32'd200;
    #5;
    
    write_enable=1;
    write_addr=5'd0;
    write_data=32'd999;
    #10;
    read_addr1=5'd0;

    $finish;
end

always #5 clk=~clk;
endmodule



