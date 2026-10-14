`timescale 1ns/1ps

module hazard_detection_unit_tb;

reg mem_read_ex;
reg [4:0] rd_ex;
reg [4:0] rs1_id;
reg [4:0] rs2_id;
reg uses_rs1;
reg uses_rs2;

wire stall;

integer errors;

hazard_detection_unit uut(
    .mem_read_ex(mem_read_ex),
    .rd_ex(rd_ex),
    .rs1_id(rs1_id),
    .rs2_id(rs2_id),
    .stall(stall),
    .uses_rs1(uses_rs1),
    .uses_rs2(uses_rs2)
);

initial begin
    $dumpfile("hazard_detection_unit.vcd");
    $dumpvars(0,hazard_detection_unit_tb);
    mem_read_ex = 0;
    rd_ex = 5'd5;
    rs1_id = 5'd5;
    rs2_id = 5'd3;
    uses_rs1 = 1;
    uses_rs2 = 1;
    errors = 0;
    
    #10;
    if (stall) 
        errors = errors + 1;
    mem_read_ex = 1;
    
    #10;
    if (!stall)
        errors = errors + 1;
    rd_ex = 5'd5;
    rs1_id = 5'd2;
    rs2_id = 5'd5;
    uses_rs1 = 1;
    uses_rs2 = 0;

    #10;
    if (stall)
        errors = errors + 1;
    rd_ex = 5'd5;
    rs1_id = 5'd2;
    rs2_id = 5'd5;
    uses_rs1 = 1;
    uses_rs2 = 1;

    #10;
    if (!stall)
        errors = errors + 1;
    rd_ex = 5'd0;
    rs1_id = 5'd0;
    rs2_id = 5'd0;
    uses_rs1 = 1;
    uses_rs2 = 1;

    #10;
    if (stall)
        errors = errors + 1;

    #10;
    if (!errors)
        $display("ALL HAZARD DETECTION PASSED");
    else 
        $display("%0d TESTS FAILED", errors);
    $finish;
end

endmodule