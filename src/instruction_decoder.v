`timescale 1ns / 1ps

module instruction_decoder (
    input wire [31:0] instruction,

    output wire [6:0] opcode,
    output wire [4:0] rd,
    output wire [2:0] funct3,
    output wire [4:0] rs1,
    output wire [4:0] rs2,
    output wire [6:0] funct7,

    output wire [2:0] instruction_type,
    output wire [2:0] alu_control,
    output wire signed [31:0] immediate,

    output wire reg_write,
    output wire mem_read,
    output wire mem_write,
    output wire alu_src,
    output wire branch,
    output wire illegal_instruction
);

    field_extractor field_extractor_inst (
        .instruction(instruction),
        .opcode(opcode),
        .rd(rd),
        .funct3(funct3),
        .rs1(rs1),
        .rs2(rs2),
        .funct7(funct7)
    );

    immediate_generator immediate_generator_inst (
        .instruction(instruction),
        .opcode(opcode),
        .immediate(immediate)
    );

    control_unit control_unit_inst (
        .opcode(opcode),
        .funct3(funct3),
        .funct7(funct7),

        .instruction_type(instruction_type),
        .alu_control(alu_control),

        .reg_write(reg_write),
        .mem_read(mem_read),
        .mem_write(mem_write),
        .alu_src(alu_src),
        .branch(branch),
        .illegal_instruction(illegal_instruction)
    );

endmodule