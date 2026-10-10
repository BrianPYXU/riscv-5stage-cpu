`timescale 1ns/1ps

module forwarding_unit_tb;

reg [4:0] rs1_ex;
reg [4:0] rs2_ex;
reg [4:0] rd_mem;
reg reg_write_mem;
reg [4:0] rd_wb;
reg reg_write_wb;

wire [1:0] forward_a;
wire [1:0] forward_b;

integer errors;
forwarding_unit uut(
    .rs1_ex(rs1_ex),
    .rs2_ex(rs2_ex),
    .rd_mem(rd_mem),
    .reg_write_mem(reg_write_mem),
    .rd_wb(rd_wb),
    .reg_write_wb(reg_write_wb),

    .forward_a(forward_a),
    .forward_b(forward_b)
);

initial begin
    $dumpfile("forwarding_unit.vcd");
    $dumpvars(0,forwarding_unit_tb);
    rs1_ex = 5'd1;
    rs2_ex = 5'd2;
    rd_mem = 5'd3;
    reg_write_mem = 1;
    reg_write_wb = 1;
    rd_wb = 5'd4;
    errors = 0;
    
    #1;
    if (forward_a != 2'b00 || forward_b != 2'b00)
        errors = errors + 1;
        
    #10;
    rd_mem = 5'd1;

    #1;
    if (forward_a != 2'b10 || forward_b != 2'b00)
        errors = errors + 1;

    #10;
    rd_mem = 5'd6;
    rd_wb = 5'd1;

    #1;
    if (forward_a != 2'b01 || forward_b != 2'b00)
        errors = errors + 1;

    #10;
    rd_mem = 5'd2;
    #1;
    if (forward_a != 2'b01 ||forward_b != 2'b10)
        errors = errors + 1;

    #10;
    rd_mem = 5'd0;
    rd_wb = 5'd2;
    rs1_ex = 5'd7;
    #1;
    if (forward_a != 2'b00 || forward_b != 2'b01)
        errors = errors + 1;
    
    #10;
    rd_wb = 5'd7;
    rd_mem = 5'd7;
    #1;
    if (forward_a != 2'b10 || forward_b != 2'b00)
        errors = errors + 1;    

    #10;
    if (errors == 0)
        $display("ALL TESTS PASSED");
    else
        $display("%0d TESTS FAILED", errors);
    
    #1;
    $finish;  


end

endmodule