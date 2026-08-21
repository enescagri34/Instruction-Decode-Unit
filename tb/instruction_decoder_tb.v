`timescale 1ns / 1ps

module instruction_decoder_tb;

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

    integer passed_tests;
    integer failed_tests;

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
     * Beklenen değerlerle gerçek çıktıları karşılaştırır.
     */
    task check_test;

        input [8*30-1:0] test_name;

        input [2:0] expected_instruction_type;
        input [2:0] expected_alu_control;
        input signed [31:0] expected_immediate;

        input expected_reg_write;
        input expected_mem_read;
        input expected_mem_write;
        input expected_alu_src;
        input expected_branch;
        input expected_illegal;

        begin
            if (
                instruction_type    === expected_instruction_type &&
                alu_control         === expected_alu_control &&
                immediate           === expected_immediate &&
                reg_write           === expected_reg_write &&
                mem_read            === expected_mem_read &&
                mem_write           === expected_mem_write &&
                alu_src             === expected_alu_src &&
                branch              === expected_branch &&
                illegal_instruction === expected_illegal
            ) begin

                $display("[PASS] %s", test_name);
                passed_tests = passed_tests + 1;

            end
            else begin

                $display("[FAIL] %s", test_name);

                $display(
                    "  instruction_type: expected=%b actual=%b",
                    expected_instruction_type,
                    instruction_type
                );

                $display(
                    "  alu_control     : expected=%b actual=%b",
                    expected_alu_control,
                    alu_control
                );

                $display(
                    "  immediate       : expected=%0d actual=%0d",
                    expected_immediate,
                    immediate
                );

                $display(
                    "  reg_write       : expected=%b actual=%b",
                    expected_reg_write,
                    reg_write
                );

                $display(
                    "  mem_read        : expected=%b actual=%b",
                    expected_mem_read,
                    mem_read
                );

                $display(
                    "  mem_write       : expected=%b actual=%b",
                    expected_mem_write,
                    mem_write
                );

                $display(
                    "  alu_src         : expected=%b actual=%b",
                    expected_alu_src,
                    alu_src
                );

                $display(
                    "  branch          : expected=%b actual=%b",
                    expected_branch,
                    branch
                );

                $display(
                    "  illegal         : expected=%b actual=%b",
                    expected_illegal,
                    illegal_instruction
                );

                failed_tests = failed_tests + 1;
            end
        end
    endtask

    initial begin

        $dumpfile("wave/decoder.vcd");
        $dumpvars(0, instruction_decoder_tb);

        passed_tests = 0;
        failed_tests = 0;

        /*
         * TEST 1
         * ADD x5, x6, x7
         */
        instruction =
            32'b0000000_00111_00110_000_00101_0110011;

        #10;

        check_test(
            "ADD x5, x6, x7",
            3'b001,
            3'b000,
            32'sd0,
            1'b1,
            1'b0,
            1'b0,
            1'b0,
            1'b0,
            1'b0
        );

        /*
         * TEST 2
         * SUB x8, x5, x6
         */
        instruction =
            32'b0100000_00110_00101_000_01000_0110011;

        #10;

        check_test(
            "SUB x8, x5, x6",
            3'b001,
            3'b001,
            32'sd0,
            1'b1,
            1'b0,
            1'b0,
            1'b0,
            1'b0,
            1'b0
        );

        /*
         * TEST 3
         * ADDI x5, x6, 10
         */
        instruction =
            32'b000000001010_00110_000_00101_0010011;

        #10;

        check_test(
            "ADDI x5, x6, 10",
            3'b010,
            3'b000,
            32'sd10,
            1'b1,
            1'b0,
            1'b0,
            1'b1,
            1'b0,
            1'b0
        );

        /*
         * TEST 4
         * ADDI x5, x6, -4
         */
        instruction =
            32'b111111111100_00110_000_00101_0010011;

        #10;

        check_test(
            "ADDI x5, x6, -4",
            3'b010,
            3'b000,
            -32'sd4,
            1'b1,
            1'b0,
            1'b0,
            1'b1,
            1'b0,
            1'b0
        );

        /*
         * TEST 5
         * LW x5, 4(x6)
         */
        instruction =
            32'b000000000100_00110_010_00101_0000011;

        #10;

        check_test(
            "LW x5, 4(x6)",
            3'b011,
            3'b000,
            32'sd4,
            1'b1,
            1'b1,
            1'b0,
            1'b1,
            1'b0,
            1'b0
        );

        /*
         * TEST 6
         * SW x5, 4(x6)
         */
        instruction =
            32'b0000000_00101_00110_010_00100_0100011;

        #10;

        check_test(
            "SW x5, 4(x6)",
            3'b100,
            3'b000,
            32'sd4,
            1'b0,
            1'b0,
            1'b1,
            1'b1,
            1'b0,
            1'b0
        );

        /*
         * TEST 7
         * BEQ x5, x6, 8
         */
        instruction =
            32'b0000000_00110_00101_000_01000_1100011;

        #10;

        check_test(
            "BEQ x5, x6, 8",
            3'b101,
            3'b001,
            32'sd8,
            1'b0,
            1'b0,
            1'b0,
            1'b0,
            1'b1,
            1'b0
        );

        /*
         * TEST 8
         * Geçersiz opcode
         */
        instruction = 32'hFFFFFFFF;

        #10;

        check_test(
            "ILLEGAL INSTRUCTION",
            3'b000,
            3'b000,
            32'sd0,
            1'b0,
            1'b0,
            1'b0,
            1'b0,
            1'b0,
            1'b1
        );

        $display("");
        $display("========================================");
        $display("TEST SUMMARY");
        $display("========================================");
        $display("Passed tests : %0d", passed_tests);
        $display("Failed tests : %0d", failed_tests);
        $display("Total tests  : %0d", passed_tests + failed_tests);

        if (failed_tests == 0)
            $display("RESULT       : ALL TESTS PASSED");
        else
            $display("RESULT       : SOME TESTS FAILED");

        $display("========================================");

        #10;
        $finish;
    end

endmodule