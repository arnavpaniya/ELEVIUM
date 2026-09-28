`timescale 1ns/1ps

module sipo_tb;

    reg       clk;
    reg       reset;
    reg       enable;
    reg       serial_in;

    wire [7:0] parallel_out;
    wire      valid;

    integer i;
    integer errors;

    reg [7:0] test_data;

    sipo uut (
        .clk         (clk),
        .reset       (reset),
        .enable      (enable),
        .serial_in   (serial_in),
        .parallel_out(parallel_out),
        .valid       (valid)
    );

    // 10 ns clock period
    always #5 clk = ~clk;

    initial begin

        $dumpfile("sim/waves/sipo.vcd");
        $dumpvars(0, sipo_tb);

        errors = 0;

        clk       = 1'b0;
        reset     = 1'b1;
        enable    = 1'b0;
        serial_in = 1'b0;

        // Reset
        @(posedge clk);
        #1;

        reset = 1'b0;

        // Test data
        test_data = 8'b10110010;

        enable = 1'b1;

        // Send LSB first
        for (i = 0; i < 8; i = i + 1) begin

            serial_in = test_data[i];

            @(posedge clk);
            #1;

        end

        enable = 1'b0;

        // Check received data
        if (parallel_out !== test_data) begin

            $display(
                "ERROR: Expected=%b | Got=%b",
                test_data,
                parallel_out
            );

            errors = errors + 1;

        end

        else begin
            $display("PASS: SIPO received correct parallel data");
        end

        // Check valid
        if (valid !== 1'b1) begin
            $display("ERROR: valid was not asserted");
            errors = errors + 1;
        end

        else begin
            $display("PASS: valid asserted after 8 bits");
        end

        @(posedge clk);
        #1;

        if (valid !== 1'b0) begin
            $display("ERROR: valid did not return low");
            errors = errors + 1;
        end

        // Final result
        if (errors == 0) begin
            $display("--------------------------------");
            $display("SIPO TEST PASSED");
            $display("--------------------------------");
        end
        else begin
            $display("--------------------------------");
            $display("SIPO TEST FAILED: %0d errors", errors);
            $display("--------------------------------");
        end

        $finish;

    end

endmodule