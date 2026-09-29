`timescale 1ns/1ps

module fifo_tb;

    reg clk;
    reg reset;

    reg write_en;
    reg [7:0] write_data;

    reg read_en;
    wire [7:0] read_data;

    wire full;
    wire empty;

    integer errors;

    fifo #(
        .DATA_WIDTH(8),
        .DEPTH(16)
    ) uut (
        .clk       (clk),
        .reset     (reset),
        .write_en  (write_en),
        .write_data(write_data),
        .read_en   (read_en),
        .read_data (read_data),
        .full      (full),
        .empty     (empty)
    );

    always #5 clk = ~clk;

    initial begin

        $dumpfile("sim/waves/fifo.vcd");
        $dumpvars(0, fifo_tb);

        clk = 1'b0;
        reset = 1'b1;

        write_en = 1'b0;
        write_data = 8'b0;

        read_en = 1'b0;

        errors = 0;

        // Reset
        @(posedge clk);
        #1;

        reset = 1'b0;

        // Check empty after reset
        if (!empty) begin
            $display("ERROR: FIFO should be empty after reset");
            errors = errors + 1;
        end
        else begin
            $display("PASS: FIFO empty after reset");
        end

        // ------------------------------------------------
        // Write data
        // ------------------------------------------------

        write_data = 8'hA5;
        write_en = 1'b1;

        @(posedge clk);
        #1;

        write_en = 1'b0;

        if (empty) begin
            $display("ERROR: FIFO still empty after write");
            errors = errors + 1;
        end
        else begin
            $display("PASS: Data successfully written");
        end

        // ------------------------------------------------
        // Read data
        // ------------------------------------------------

        read_en = 1'b1;

        @(posedge clk);
        #1;

        read_en = 1'b0;

        if (read_data !== 8'hA5) begin
            $display(
                "ERROR: Expected=0xA5 | Got=0x%h",
                read_data
            );
            errors = errors + 1;
        end
        else begin
            $display("PASS: Correct data read from FIFO");
        end

        @(posedge clk);
        #1;

        if (!empty) begin
            $display("ERROR: FIFO should be empty after read");
            errors = errors + 1;
        end
        else begin
            $display("PASS: FIFO empty after read");
        end

        // ------------------------------------------------
        // Final result
        // ------------------------------------------------

        if (errors == 0) begin
            $display("--------------------------------");
            $display("FIFO TEST PASSED");
            $display("--------------------------------");
        end
        else begin
            $display("--------------------------------");
            $display("FIFO TEST FAILED: %0d errors", errors);
            $display("--------------------------------");
        end

        $finish;

    end

endmodule