`timescale 1ns / 1ps

module control_unit (
    input wire [6:0] opcode,
    input wire [2:0] funct3,
    input wire [6:0] funct7,

    output reg [2:0] instruction_type,
    output reg [2:0] alu_control,

    output reg reg_write,
    output reg mem_read,
    output reg mem_write,
    output reg alu_src,
    output reg branch,
    output reg illegal_instruction
);

    localparam TYPE_UNKNOWN = 3'b000;
    localparam TYPE_R       = 3'b001;
    localparam TYPE_I       = 3'b010;
    localparam TYPE_LOAD    = 3'b011;
    localparam TYPE_STORE   = 3'b100;
    localparam TYPE_BRANCH  = 3'b101;

    localparam ALU_ADD = 3'b000;
    localparam ALU_SUB = 3'b001;

    always @(*) begin
        instruction_type    = TYPE_UNKNOWN;
        alu_control         = ALU_ADD;

        reg_write           = 1'b0;
        mem_read            = 1'b0;
        mem_write           = 1'b0;
        alu_src             = 1'b0;
        branch              = 1'b0;
        illegal_instruction = 1'b0;

        case (opcode)

            // ADD ve SUB
            7'b0110011: begin
                instruction_type = TYPE_R;
                reg_write        = 1'b1;

                if (
                    funct3 == 3'b000 &&
                    funct7 == 7'b0000000
                ) begin
                    alu_control = ALU_ADD;
                end
                else if (
                    funct3 == 3'b000 &&
                    funct7 == 7'b0100000
                ) begin
                    alu_control = ALU_SUB;
                end
                else begin
                    reg_write           = 1'b0;
                    illegal_instruction = 1'b1;
                end
            end

            // ADDI
            7'b0010011: begin
                instruction_type = TYPE_I;
                reg_write        = 1'b1;
                alu_src          = 1'b1;
                alu_control      = ALU_ADD;

                if (funct3 != 3'b000) begin
                    reg_write           = 1'b0;
                    illegal_instruction = 1'b1;
                end
            end

            // LW
            7'b0000011: begin
                instruction_type = TYPE_LOAD;
                reg_write        = 1'b1;
                mem_read         = 1'b1;
                alu_src          = 1'b1;
                alu_control      = ALU_ADD;

                if (funct3 != 3'b010) begin
                    reg_write           = 1'b0;
                    mem_read            = 1'b0;
                    illegal_instruction = 1'b1;
                end
            end

            // SW
            7'b0100011: begin
                instruction_type = TYPE_STORE;
                mem_write        = 1'b1;
                alu_src          = 1'b1;
                alu_control      = ALU_ADD;

                if (funct3 != 3'b010) begin
                    mem_write           = 1'b0;
                    illegal_instruction = 1'b1;
                end
            end

            // BEQ
            7'b1100011: begin
                instruction_type = TYPE_BRANCH;
                branch           = 1'b1;
                alu_control      = ALU_SUB;

                if (funct3 != 3'b000) begin
                    branch              = 1'b0;
                    illegal_instruction = 1'b1;
                end
            end

            default: begin
                illegal_instruction = 1'b1;
            end

        endcase
    end

endmodule