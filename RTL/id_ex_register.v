module id_ex_register(
    input clk,
    input reset,
    input stall,
    input flush,

    input [31:0] read_data1_in,
    input [31:0] read_data2_in,
    input [31:0] immediate_in,
    input [4:0] rd_in,
    input [3:0] alu_control_in,
    input alu_src_in,
    input reg_write_in,
    input mem_read_in,
    input mem_write_in,
    input mem_to_reg_in,

    output reg [31:0] read_data1_out,
    output reg [31:0] read_data2_out,
    output reg [31:0] immediate_out,
    output reg [4:0] rd_out,
    output reg [3:0] alu_control_out,
    output reg alu_src_out,
    output reg reg_write_out,
    output reg mem_read_out,
    output reg mem_write_out,
    output reg mem_to_reg_out
);
always @(posedge clk) begin
    if (reset) begin
        read_data1_out <= 32'd0;
        read_data2_out <= 32'd0;  
        immediate_out <= 32'd0;
        rd_out <= 5'd0;
        alu_control_out <= 4'b0000;
        alu_src_out <= 1'b0; 
        reg_write_out <= 1'b0;
        mem_read_out <= 1'b0;
        mem_write_out <= 1'b0;
        mem_to_reg_out <= 1'b0;
    end
    else if (flush) begin
        read_data1_out <= 32'd0;
        read_data2_out <= 32'd0;
        immediate_out <= 32'd0;
        rd_out <= 5'd0;
        alu_control_out <= 4'b0000;
        alu_src_out <= 1'b0;
        reg_write_out <= 1'b0;
        mem_read_out <= 1'b0;
        mem_write_out <= 1'b0;
        mem_to_reg_out <= 1'b0;
    end
    else if (!stall) begin
        read_data1_out <= read_data1_in;
        read_data2_out <= read_data2_in;
        immediate_out <= immediate_in;
        rd_out <= rd_in;
        alu_control_out <= alu_control_in;
        alu_src_out <= alu_src_in;
        reg_write_out <= reg_write_in;
        mem_read_out <= mem_read_in;
        mem_write_out <= mem_write_in;
        mem_to_reg_out <= mem_to_reg_in;
    end
end
endmodule