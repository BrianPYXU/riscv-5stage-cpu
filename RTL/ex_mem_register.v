module ex_mem_register(
    input clk,
    input reset, 
    input stall,
    input flush,

    input [31:0] alu_result_in,
    input [31:0] store_data_in,
    input [4:0] rd_in,
    input reg_write_in,
    input mem_read_in,
    input mem_write_in,

    output reg [31:0] alu_result_out,
    output reg [31:0] store_data_out,
    output reg [4:0] rd_out,
    output reg reg_write_out,
    output reg mem_read_out,
    output reg mem_write_out 
);

always @(posedge clk) begin
    if (reset) begin
       alu_result_out <= 32'd0;
       store_data_out <= 32'd0;
       rd_out <= 5'd0;
       reg_write_out <= 0;
       mem_read_out <= 0;
       mem_write_out <= 0;
    end
    else if (flush) begin
       alu_result_out <= 32'd0;
       store_data_out <= 32'd0;
       rd_out <= 5'd0;
       reg_write_out <= 0;
       mem_read_out <= 0;
       mem_write_out <= 0;
    end
    else if (!stall) begin
       alu_result_out <= alu_result_in;
       store_data_out <= store_data_in;
       rd_out <= rd_in;
       reg_write_out <= reg_write_in;
       mem_read_out <= mem_read_in;
       mem_write_out <= mem_write_in;
    end
end
endmodule