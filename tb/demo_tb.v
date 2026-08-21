`timescale 1ns / 1ps

module demo_tb;

    reg [31:0] instruction;

    wire [6:0] opcode;
    wire [4:0] rd;
    wire [2:0] funct3;
    wire [4:0] rs1;
    wire [4:0] rs2;
    wire [6:0] funct7;

    wire [2:0] instruction_type;
    wire [2:0] alu_control;
    wire signed [31:0] immediate;

    wire reg_write;
    wire mem_read;
    wire mem_write;
    wire alu_src;
    wire branch;
    wire illegal_instruction;

    /*
     * Instruction Decoder modülü
     */
    instruction_decoder dut (
        .instruction(instruction),

        .opcode(opcode),
        .rd(rd),
        .funct3(funct3),
        .rs1(rs1),
        .rs2(rs2),
        .funct7(funct7),

        .instruction_type(instruction_type),
        .alu_control(alu_control),
        .immediate(immediate),

        .reg_write(reg_write),
        .mem_read(mem_read),
        .mem_write(mem_write),
        .alu_src(alu_src),
        .branch(branch),
        .illegal_instruction(illegal_instruction)
    );

    /*
     * Instruction type kodunu okunabilir metne çevirir.
     */
    task print_instruction_type;
        begin
            case (instruction_type)
                3'b001: $write("R-Type");
                3'b010: $write("I-Type");
                3'b011: $write("Load");
                3'b100: $write("Store");
                3'b101: $write("Branch");
                default: $write("Unknown");
            endcase
        end
    endtask

    /*
     * ALU control kodunu okunabilir metne çevirir.
     *
     * Illegal instruction durumunda ALU işlemi geçerli
     * olmadığı için Not Applicable gösterilir.
     */
    task print_alu_operation;
        begin
            if (illegal_instruction) begin
                $write("Not Applicable");
            end
            else begin
                case (alu_control)
                    3'b000: $write("ADD");
                    3'b001: $write("SUB");
                    default: $write("UNKNOWN");
                endcase
            end
        end
    endtask

    /*
     * Kontrol sinyalini okunabilir metne çevirir.
     */
    task print_signal_state;
        input signal_value;

        begin
            if (signal_value == 1'b1)
                $write("ENABLED");
            else
                $write("DISABLED");
        end
    endtask

    /*
     * Komut tipine göre yalnızca anlamlı register
     * alanlarını ve immediate değerini gösterir.
     */
    task print_operand_fields;
        begin
            case (instruction_type)

                /*
                 * R-Type
                 *
                 * ADD rd, rs1, rs2
                 * SUB rd, rs1, rs2
                 */
                3'b001: begin
                    $display(
                        "Destination Register : x%0d",
                        rd
                    );

                    $display(
                        "Source Register 1    : x%0d",
                        rs1
                    );

                    $display(
                        "Source Register 2    : x%0d",
                        rs2
                    );

                    $display(
                        "Immediate            : Not Used"
                    );
                end

                /*
                 * I-Type
                 *
                 * ADDI rd, rs1, immediate
                 */
                3'b010: begin
                    $display(
                        "Destination Register : x%0d",
                        rd
                    );

                    $display(
                        "Source Register 1    : x%0d",
                        rs1
                    );

                    $display(
                        "Source Register 2    : Not Used"
                    );

                    $display(
                        "Immediate            : %0d",
                        immediate
                    );
                end

                /*
                 * Load
                 *
                 * LW rd, immediate(rs1)
                 */
                3'b011: begin
                    $display(
                        "Destination Register : x%0d",
                        rd
                    );

                    $display(
                        "Base Register        : x%0d",
                        rs1
                    );

                    $display(
                        "Source Register 2    : Not Used"
                    );

                    $display(
                        "Immediate            : %0d",
                        immediate
                    );
                end

                /*
                 * Store
                 *
                 * SW rs2, immediate(rs1)
                 */
                3'b100: begin
                    $display(
                        "Destination Register : Not Used"
                    );

                    $display(
                        "Base Register        : x%0d",
                        rs1
                    );

                    $display(
                        "Source Register      : x%0d",
                        rs2
                    );

                    $display(
                        "Immediate            : %0d",
                        immediate
                    );
                end

                /*
                 * Branch
                 *
                 * BEQ rs1, rs2, immediate
                 */
                3'b101: begin
                    $display(
                        "Destination Register : Not Used"
                    );

                    $display(
                        "Source Register 1    : x%0d",
                        rs1
                    );

                    $display(
                        "Source Register 2    : x%0d",
                        rs2
                    );

                    $display(
                        "Branch Offset        : %0d",
                        immediate
                    );
                end

                /*
                 * Geçersiz instruction
                 */
                default: begin
                    $display(
                        "Register Fields      : Not Applicable"
                    );

                    $display(
                        "Immediate            : Not Applicable"
                    );
                end

            endcase
        end
    endtask

    /*
     * Bir komutun decode sonucunu açıklamalı olarak
     * terminalde gösterir.
     */
    task show_demo;

        input [8*30-1:0] assembly_name;

        begin
            $display("");
            $display(
                "=================================================="
            );

            $display(
                "RISC-V INSTRUCTION DECODE DEMO"
            );

            $display(
                "=================================================="
            );

            $display(
                "Assembly             : %s",
                assembly_name
            );

            $display(
                "Machine Code         : %b",
                instruction
            );

            $display(
                "Opcode               : %b",
                opcode
            );

            $display(
                "Funct3               : %b",
                funct3
            );

            $display(
                "Funct7               : %b",
                funct7
            );

            $write("Instruction Type     : ");
            print_instruction_type();
            $display("");

            $write("ALU Operation        : ");
            print_alu_operation();
            $display("");

            $display(
                "--------------------------------------------------"
            );

            print_operand_fields();

            $display(
                "--------------------------------------------------"
            );

            $write("Register Write       : ");
            print_signal_state(reg_write);
            $display("");

            $write("Memory Read          : ");
            print_signal_state(mem_read);
            $display("");

            $write("Memory Write         : ");
            print_signal_state(mem_write);
            $display("");

            $write("ALU Immediate Source : ");
            print_signal_state(alu_src);
            $display("");

            $write("Branch               : ");
            print_signal_state(branch);
            $display("");

            $write("Illegal Instruction  : ");
            print_signal_state(illegal_instruction);
            $display("");

            $display(
                "=================================================="
            );
        end
    endtask

    initial begin

        /*
         * GTKWave için VCD dosyası
         */
        $dumpfile("wave/demo.vcd");
        $dumpvars(0, demo_tb);

        /*
         * DEMO 1
         *
         * ADD x5, x6, x7
         */
        instruction =
            32'b0000000_00111_00110_000_00101_0110011;

        #10;
        show_demo("ADD x5, x6, x7");

        /*
         * DEMO 2
         *
         * ADDI x5, x6, 10
         */
        instruction =
            32'b000000001010_00110_000_00101_0010011;

        #10;
        show_demo("ADDI x5, x6, 10");

        /*
         * DEMO 3
         *
         * LW x5, 4(x6)
         */
        instruction =
            32'b000000000100_00110_010_00101_0000011;

        #10;
        show_demo("LW x5, 4(x6)");

        /*
         * DEMO 4
         *
         * SW x5, 4(x6)
         */
        instruction =
            32'b0000000_00101_00110_010_00100_0100011;

        #10;
        show_demo("SW x5, 4(x6)");

        /*
         * DEMO 5
         *
         * BEQ x5, x6, 8
         */
        instruction =
            32'b0000000_00110_00101_000_01000_1100011;

        #10;
        show_demo("BEQ x5, x6, 8");

        /*
         * DEMO 6
         *
         * Desteklenmeyen opcode
         */
        instruction = 32'hFFFFFFFF;

        #10;
        show_demo("ILLEGAL INSTRUCTION");

        #10;
        $finish;
    end

endmodule