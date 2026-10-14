module instruction_decoder(
    input [31:0] instruction,
    output [6:0] opcode,
    output [4:0] rd,
    output [2:0] funct3,
    output [4:0] rs1,
    output [4:0] rs2,
    output [6:0] funct7,
    output reg reg_write,
    output reg mem_read,
    output reg mem_write,
    output reg mem_to_reg,
    output reg [3:0] alu_control,
    output reg alu_src,
    output reg branch,
    output reg uses_rs1,
    output reg uses_rs2
);

assign opcode = instruction[6:0];
assign rd = instruction[11:7];
assign funct3 = instruction[14:12];
assign rs1 = instruction[19:15];
assign rs2 = instruction[24:20];
assign funct7 = instruction[31:25];
always @(*)begin
    alu_control = 4'b1111;
    reg_write = 0;
    mem_read = 0;
    mem_write = 0;
    mem_to_reg = 0;
    alu_src = 0;
    branch = 0;
    uses_rs1 = 0;
    uses_rs2 = 0;
    if(opcode == 7'b0110011 && funct3 == 3'b000 && funct7 == 7'b0000000) begin
        alu_control = 4'b0000;
        reg_write = 1;
        uses_rs1 = 1;
        uses_rs2 = 1;
    end
    else if(opcode == 7'b0110011 && funct3 == 3'b000 && funct7 == 7'b0100000) begin
        alu_control = 4'b0001;
        reg_write = 1;
        uses_rs1 = 1;
        uses_rs2 = 1;
    end
    else  if(opcode == 7'b0010011 && funct3 == 3'b000) begin
        alu_src = 1;
        reg_write = 1;
        uses_rs1 = 1;
        uses_rs2 = 0;
        alu_control = 4'b0000;      
    end    
    else if(opcode == 7'b0000011 && funct3 == 3'b010) begin
        mem_read = 1;
        reg_write = 1;
        mem_to_reg = 1;   
        alu_src = 1;
        alu_control = 4'b0000;
        uses_rs1 = 1;
        uses_rs2 = 0;
    
    end
    else if(opcode == 7'b0100011 && funct3 == 3'b010) begin
        mem_write = 1;
        alu_src = 1;
        alu_control = 4'b0000;
        uses_rs1 = 1;
        uses_rs2 = 1;
    end
    else if(opcode == 7'b1100011 && funct3 == 3'b000) begin
        branch = 1;
        uses_rs1 = 1;
        uses_rs2 = 1;
    end
    else if(opcode == 7'b0110011 && funct3 == 3'b111 && funct7 == 7'b0000000) begin
        alu_control = 4'b0010;
        reg_write = 1;
        uses_rs1 = 1;
        uses_rs2 = 1;
    end
    else if(opcode == 7'b0110011 && funct3 == 3'b110 && funct7 == 7'b0000000) begin 
        reg_write = 1;
        alu_control = 4'b0011;
        uses_rs1 = 1;
        uses_rs2 = 1;
    end
    else if(opcode == 7'b0110011 && funct3 == 3'b100 && funct7 == 7'b0000000) begin
        alu_control = 4'b0100;
        reg_write = 1;
        uses_rs1 = 1;
        uses_rs2 = 1;
    end
    else if(opcode == 7'b0110011 && funct3 == 3'b010 && funct7 == 7'b0000000) begin
        alu_control = 4'b0101;
        reg_write = 1;
        uses_rs1 = 1;
        uses_rs2 = 1;
    end
end 
endmodule   