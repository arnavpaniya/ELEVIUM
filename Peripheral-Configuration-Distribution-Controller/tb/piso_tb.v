`timescale 1ns/1ps

module piso_tb;

    reg       clk;
    reg       reset;
    reg       load;
    reg       enable;
    reg [7:0] parallel_in;

    wire      serial_out;
    wire      valid;

    integer i;
    integer errors;

    reg [7:0] test_data;
    reg [7:0] expected_data;

    piso uut (
        .clk        (clk),
        .reset      (reset),
        .load       (load),
        .enable     (enable),
        .parallel_in(parallel_in),
        .serial_out (serial_out),
        .valid      (valid)
    );

    // 10 ns clock period
    always #5 clk = ~clk;

    initial begin

        $dumpfile("sim/waves/piso.vcd");
        $dumpvars(0, piso_tb);

        errors = 0;

        clk         = 1'b0;
        reset       = 1'b1;
        load        = 1'b0;
        enable      = 1'b0;
        parallel_in = 8'b0;

        // Reset
        @(posedge clk);
        #1;

        reset = 1'b0;

        // ------------------------------------------------
        // Test 1
        // ------------------------------------------------

        test_data = 8'b10110010;
        expected_data = test_data;

        parallel_in = test_data;
        load = 1'b1;

        @(posedge clk);
        #1;

        load = 1'b0;
        enable = 1'b1;

        // Check 8 transmitted bits
        for (i = 0; i < 8; i = i + 1) begin

            #1;

            if (serial_out !== expected_data[i]) begin
                $display(
                    "ERROR: Bit %0d | Expected=%b | Got=%b",
                    i,
                    expected_data[i],
                    serial_out
                );
                errors = errors + 1;
            end

            @(posedge clk);
        end

        #1;

        if (valid !== 1'b1) begin
            $display("ERROR: valid was not asserted after 8 bits");
            errors = errors + 1;
        end

        else begin
            $display("PASS: First 8-bit transmission");
        end

        enable = 1'b0;

        @(posedge clk);
        #1;

        if (valid !== 1'b0) begin
            $display("ERROR: valid did not return low");
            errors = errors + 1;
        end

        // ------------------------------------------------
        // Test 2 - second byte
        // ------------------------------------------------

        test_data = 8'b01100101;
        expected_data = test_data;

        parallel_in = test_data;
        load = 1'b1;

        @(posedge clk);
        #1;

        load = 1'b0;
        enable = 1'b1;

        for (i = 0; i < 8; i = i + 1) begin

            #1;

            if (serial_out !== expected_data[i]) begin
                $display(
                    "ERROR: Second transmission - Bit %0d | Expected=%b | Got=%b",
                    i,
                    expected_data[i],
                    serial_out
                );
                errors = errors + 1;
            end

            @(posedge clk);
        end

        #1;

        if (valid !== 1'b1) begin
            $display("ERROR: valid was not asserted for second transmission");
            errors = errors + 1;
        end

        else begin
            $display("PASS: Second 8-bit transmission");
        end

        // ------------------------------------------------
        // Final result
        // ------------------------------------------------

        enable = 1'b0;

        @(posedge clk);
        #1;

        if (errors == 0) begin
            $display("--------------------------------");
            $display("PISO TEST PASSED");
            $display("--------------------------------");
        end

        else begin
            $display("--------------------------------");
            $display("PISO TEST FAILED: %0d errors", errors);
            $display("--------------------------------");
        end

        $finish;

    end

endmodule