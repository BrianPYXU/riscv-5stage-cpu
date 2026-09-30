module datapath_top(
    input clk,
    input write_enable,
    input [31:0] instruction,
    output [31:0] alu_result
);
wire [31:0] data;
reg alu_src;
wire [31:0] immediate;
wire [4:0] rs1;
wire [4:0] rs2;
wire [4:0] rd;
wire [31:0] read_data1;
wire [31:0] read_data2;
wire [3:0] alu_control;
wire [6:0] opcode;
wire [2:0] funct3;
wire [6:0] funct7;
instruction_decoder decoder(
    .instruction(instruction),
    .opcode(opcode),
    .rd(rd),
    .funct3(funct3),
    .rs1(rs1),
    .rs2(rs2),
    .funct7(funct7),
    .alu_control(alu_control)
);

register_file regfile(
    .clk(clk),
    .write_enable(write_enable),
    .read_addr1(rs1),
    .read_addr2(rs2),
    .write_addr(rd),
    .write_data(alu_result),
    .read_data1(read_data1),
    .read_data2(read_data2)
);

alu a(
    .a(read_data1),
    .b(data),
    .control(alu_control),
    .result(alu_result)
);
immediate_generator imm_gen(
    .instruction(instruction),
    .immediate(immediate)
);
mux2 m(
    .a(read_data2),
    .b(immediate),
    .sel(alu_src),
    .y(data)
);
always @(*) begin
    if (opcode == 7'b0110011)
        alu_src = 1'b0;
    else if (opcode == 7'b0010011)
        alu_src = 1'b1;
    else
        alu_src = 1'b0;
end

endmodule