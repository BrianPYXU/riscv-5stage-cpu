`timescale 1ns/1ps

module data_memory_tb;

reg clk;
reg mem_read;
reg mem_write;
reg [31:0] address;
reg [31:0] write_data;

wire [31:0] read_data;

data_memory uut(
    .clk(clk),
    .mem_read(mem_read),
    .mem_write(mem_write),
    .address(address),
    .write_data(write_data),
    
    .read_data(read_data)
);

always #5 clk = ~clk;
initial begin
    $dumpfile("data_memory.vcd");
    $dumpvars(0,data_memory_tb);
    clk = 0;
    mem_read = 0;
    mem_write = 0;
    address = 32'd0;
    write_data = 32'd0;

    #10;
    mem_write = 1;
    address = 32'd12;
    write_data = 32'd123;

    #10;
    mem_write = 0;

    #10;
    mem_read = 1;

    #10;
    if (read_data == 32'd123)
        $display("PASS");
    else
        $display("FAIL");
    
    $finish;

end

endmodule