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

    output reg [31:0] read_data1_out,
    output reg [31:0] read_data2_out,
    output reg [31:0] immediate_out,
    output reg [4:0] rd_out,
    output reg [3:0] alu_control_out,
    output reg alu_src_out
);
always @(posedge clk) begin
    if (reset) begin
        read_data1_out <= 32'd0;
        read_data2_out <= 32'd0;  
        immediate_out <= 32'd0;
        rd_out <= 5'd0;
        alu_control_out <= 4'b0000;
        alu_src_out <= 1'b0;  
    end
    else if (flush) begin
        read_data1_out <= 32'd0;
        read_data2_out <= 32'd0;  
        immediate_out <= 32'd0;
        rd_out <= 5'd0;
        alu_control_out <= 4'b0000;
        alu_src_out <= 1'b0;   
    end
    else if (!stall) begin
        read_data1_out <= read_data1_in;
        read_data2_out <= read_data2_in;  
        immediate_out <= immediate_in;
        rd_out <= rd_in;
        alu_control_out <= alu_control_in;
        alu_src_out <= alu_src_in;  
    end
end
endmodule