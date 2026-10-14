module hazard_detection_unit(
    input mem_read_ex,
    input [4:0] rd_ex,
    input [4:0] rs1_id,
    input [4:0] rs2_id,
    input uses_rs1,
    input uses_rs2,
    output reg stall

);

always @(*) begin
    if (mem_read_ex == 1 && rd_ex != 5'd0 && ((uses_rs1 && rd_ex == rs1_id) || (uses_rs2 && rd_ex == rs2_id)))
        stall = 1;
    else 
        stall = 0;
end

endmodule
