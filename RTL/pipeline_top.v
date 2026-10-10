module pipeline_top(
    input clk,
    input reset,
    input [31:0] instruction
);


wire [31:0] pc_if;
wire [31:0] instruction_if;


wire [31:0] pc_id;
wire [31:0] instruction_id;
wire [4:0] rd_id;
wire [31:0] read_data1_id;
wire [31:0] read_data2_id;
wire [31:0] immediate_id;
wire [3:0] alu_control_id;
wire [4:0] rs1_id;
wire [4:0] rs2_id;
wire alu_src_id;
wire reg_write_id;
wire mem_read_id;
wire mem_write_id;
wire mem_to_reg_id;


wire [4:0] rd_ex;
wire [31:0] read_data1_ex;
wire [31:0] read_data2_ex;
wire [4:0] rs1_ex;
wire [4:0] rs2_ex;
wire [31:0] immediate_ex;
wire [3:0] alu_control_ex;
wire alu_src_ex;
wire reg_write_ex;
wire mem_read_ex;
wire mem_write_ex;
wire mem_to_reg_ex;
wire [31:0] alu_result_ex;
wire [31:0] alu_operand_b_ex;
wire [31:0] alu_operand_a_ex;


wire [31:0] alu_result_mem;
wire [31:0] store_data_mem;
wire [4:0] rd_mem;
wire reg_write_mem;
wire mem_read_mem;
wire mem_write_mem;
wire mem_to_reg_mem;


wire mem_to_reg_wb;
wire [31:0] memory_data_wb;
wire [31:0] alu_result_wb;
wire [4:0] rd_wb;
wire reg_write_wb;
wire [31:0] wb_data;

wire [1:0] forward_a;
wire [1:0] forward_b;
wire [31:0] forward_a_temp;
wire [31:0] forward_b_temp;
wire [31:0] forward_b_data;

assign instruction_if = instruction;

program_counter pc(
    .clk(clk),
    .reset(reset),
    .pc(pc_if)
);

if_id_register if_id_reg(
    .clk(clk),
    .reset(reset),
    .stall(1'b0),
    .flush(1'b0),

    .pc_in(pc_if),
    .pc_out(pc_id),

    .instruction_in(instruction_if),
    .instruction_out(instruction_id)
);

instruction_decoder dec(
    .instruction(instruction_id),
    .opcode(),
    .rd(rd_id),
    .funct3(),
    .rs1(rs1_id),
    .rs2(rs2_id),
    .funct7(),
    .reg_write(reg_write_id),
    .mem_read(mem_read_id),
    .mem_write(mem_write_id),
    .mem_to_reg(mem_to_reg_id),
    .alu_control(alu_control_id),
    .alu_src(alu_src_id)
);

register_file reg_file(
    .clk(clk),
    .write_enable(reg_write_wb),
    .read_addr1(rs1_id),
    .read_addr2(rs2_id),
    .write_addr(rd_wb),
    .write_data(wb_data),
    .read_data1(read_data1_id),
    .read_data2(read_data2_id)
);

immediate_generator imm_gen(
    .instruction(instruction_id),
    .immediate(immediate_id)
);

id_ex_register id_ex_reg(
    .clk(clk),
    .reset(reset),
    .stall(1'b0),
    .flush(1'b0),

    .read_data1_in(read_data1_id),
    .read_data2_in(read_data2_id),
    .immediate_in(immediate_id),
    .rd_in(rd_id),
    .alu_control_in(alu_control_id),
    .alu_src_in(alu_src_id),
    .reg_write_in(reg_write_id),
    .mem_read_in(mem_read_id),
    .mem_write_in(mem_write_id),
    .mem_to_reg_in(mem_to_reg_id),
    .rs1_in(rs1_id),
    .rs2_in(rs2_id),

    .read_data1_out(read_data1_ex),
    .read_data2_out(read_data2_ex),
    .immediate_out(immediate_ex),
    .rd_out(rd_ex),
    .alu_control_out(alu_control_ex),
    .alu_src_out(alu_src_ex),
    .reg_write_out(reg_write_ex),
    .mem_read_out(mem_read_ex),
    .mem_write_out(mem_write_ex),
    .mem_to_reg_out(mem_to_reg_ex),
    .rs1_out(rs1_ex),
    .rs2_out(rs2_ex)
    
);

mux2 mux_ex(
    .a(forward_b_data),
    .b(immediate_ex),
    .sel(alu_src_ex),
    .y(alu_operand_b_ex)
);

alu alu(
    .a(alu_operand_a_ex),
    .b(alu_operand_b_ex),
    .control(alu_control_ex),
    .result(alu_result_ex)
);

ex_mem_register ex_mem_reg(
    .clk(clk),
    .reset(reset),
    .stall(1'b0),
    .flush(1'b0),

    .alu_result_in(alu_result_ex),
    .store_data_in(read_data2_ex),
    .rd_in(rd_ex),
    .reg_write_in(reg_write_ex),
    .mem_read_in(mem_read_ex),
    .mem_write_in(mem_write_ex),
    .mem_to_reg_in(mem_to_reg_ex),

    .alu_result_out(alu_result_mem),
    .store_data_out(store_data_mem),
    .rd_out(rd_mem),
    .reg_write_out(reg_write_mem),
    .mem_read_out(mem_read_mem),
    .mem_write_out(mem_write_mem),
    .mem_to_reg_out(mem_to_reg_mem)
);

mem_wb_register mem_wb_reg(
    .clk(clk),
    .reset(reset),
    .stall(1'b0),
    .flush(1'b0),

    .alu_result_in(alu_result_mem),
    .memory_data_in(32'b0),
    .rd_in(rd_mem),
    .reg_write_in(reg_write_mem),
    .mem_to_reg_in(mem_to_reg_mem),

    .alu_result_out(alu_result_wb),
    .memory_data_out(memory_data_wb),
    .rd_out(rd_wb),
    .reg_write_out(reg_write_wb),
    .mem_to_reg_out(mem_to_reg_wb) 
);

mux2 mux_wb(
    .a(alu_result_wb),
    .b(memory_data_wb),
    .sel(mem_to_reg_wb),
    .y(wb_data)
);

forwarding_unit fwd_unit(
    .rs1_ex(rs1_ex),
    .rs2_ex(rs2_ex),
    .rd_mem(rd_mem),
    .reg_write_mem(reg_write_mem),
    .rd_wb(rd_wb),
    .reg_write_wb(reg_write_wb),

    .forward_a(forward_a),
    .forward_b(forward_b)    
);

mux2 muxa_fwd1(
    .a(read_data1_ex),
    .b(wb_data),
    .sel(forward_a[0]),
    .y(forward_a_temp)
);

mux2 muxa_fwd2(
    .a(forward_a_temp),
    .b(alu_result_mem),
    .sel(forward_a[1]),
    .y(alu_operand_a_ex)
);

mux2 muxb_fwd1(
    .a(read_data2_ex),
    .b(wb_data),
    .sel(forward_b[0]),
    .y(forward_b_temp)
);

mux2 muxb_fwd2(
    .a(forward_b_temp),
    .b(alu_result_mem),
    .sel(forward_b[1]),
    .y(forward_b_data)
);

endmodule