`timescale 1ns / 1ps

module immediate_generator (
    input  wire [31:0] instruction,
    input  wire [6:0]  opcode,

    output reg signed [31:0] immediate
);

    always @(*) begin
        immediate = 32'sd0;

        case (opcode)

            // ADDI ve LW: I-Type
            7'b0010011,
            7'b0000011: begin
                immediate = {
                    {20{instruction[31]}},
                    instruction[31:20]
                };
            end

            // SW: S-Type
            7'b0100011: begin
                immediate = {
                    {20{instruction[31]}},
                    instruction[31:25],
                    instruction[11:7]
                };
            end

            // BEQ: B-Type
            7'b1100011: begin
                immediate = {
                    {19{instruction[31]}},
                    instruction[31],
                    instruction[7],
                    instruction[30:25],
                    instruction[11:8],
                    1'b0
                };
            end

            default: begin
                immediate = 32'sd0;
            end

        endcase
    end

endmodule