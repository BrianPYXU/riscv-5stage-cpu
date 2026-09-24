module register_file(
    input clk,
    input write_enable,

    input [4:0] read_addr1,
    input [4:0] read_addr2,
    input [4:0] write_addr,

    input [31:0] write_data,

    output [31:0] read_data1,
    output [31:0] read_data2
);
reg [31:0]registers [0:31];
always @(posedge clk)begin
    if(write_enable && write_addr!=5'd0)
        registers[write_addr]<=write_data;
end
assign read_data1=(read_addr1==5'd0) ? 32'd0:registers[read_addr1];
assign read_data2=(read_addr2==5'd0) ? 32'd0:registers[read_addr2];
endmodule
