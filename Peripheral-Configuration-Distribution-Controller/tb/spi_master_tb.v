`timescale 1ns/1ps

module spi_master_tb;

    reg clk;
    reg reset;

    reg start;
    reg [7:0] tx_data;
    reg miso;

    wire mosi;
    wire sclk;
    wire cs;

    wire [7:0] rx_data;
    wire busy;
    wire done;

    integer errors;
    integer i;

    reg [7:0] expected_tx;
    reg [7:0] expected_rx;

    spi_master uut (
        .clk    (clk),
        .reset  (reset),
        .start  (start),
        .tx_data(tx_data),
        .miso   (miso),
        .mosi   (mosi),
        .sclk   (sclk),
        .cs     (cs),
        .rx_data(rx_data),
        .busy   (busy),
        .done   (done)
    );

    always #5 clk = ~clk;

    initial begin

        $dumpfile("sim/waves/spi_master.vcd");
        $dumpvars(0, spi_master_tb);

        clk = 1'b0;
        reset = 1'b1;
        start = 1'b0;
        tx_data = 8'b0;
        miso = 1'b0;

        errors = 0;

        // Reset
        @(posedge clk);
        #1;

        if (cs !== 1'b1) begin
            $display("ERROR: CS not high after reset");
            errors = errors + 1;
        end

        if (busy !== 1'b0) begin
            $display("ERROR: BUSY not low after reset");
            errors = errors + 1;
        end

        reset = 1'b0;

        // ------------------------------------------------
        // Start SPI transaction
        // ------------------------------------------------

        expected_tx = 8'b10110010;
        expected_rx = 8'b01100101;

        tx_data = expected_tx;

        start = 1'b1;

        @(posedge clk);
        #1;

        start = 1'b0;

        if (busy !== 1'b1) begin
            $display("ERROR: BUSY not asserted");
            errors = errors + 1;
        end
        else begin
            $display("PASS: SPI transaction started");
        end

        if (cs !== 1'b0) begin
            $display("ERROR: CS not asserted");
            errors = errors + 1;
        end
        else begin
            $display("PASS: CS asserted");
        end

        // ------------------------------------------------
        // Full-duplex transfer
        // ------------------------------------------------
        //
        // The DUT samples MISO during the low-to-high
        // portion of SCLK. Change MISO before each
        // sampling edge.
        //
        // LSB first
        // ------------------------------------------------

        for (i = 0; i < 8; i = i + 1) begin

            miso = expected_rx[i];

            // Wait for SCLK rising edge
            @(posedge sclk);
            #1;

            if (i == 0) begin
                $display("PASS: SPI clock started");
            end

        end

        // Allow DUT to finish transaction
        wait(done == 1'b1);
        #1;

        // ------------------------------------------------
        // Check received data
        // ------------------------------------------------

        if (rx_data !== expected_rx) begin

            $display(
                "ERROR: RX data | Expected=%b | Got=%b",
                expected_rx,
                rx_data
            );

            errors = errors + 1;

        end
        else begin
            $display("PASS: Correct RX data received");
        end

        // ------------------------------------------------
        // Check transaction completion
        // ------------------------------------------------

        if (busy !== 1'b0) begin
            $display("ERROR: BUSY did not deassert");
            errors = errors + 1;
        end
        else begin
            $display("PASS: BUSY deasserted");
        end

        if (cs !== 1'b1) begin
            $display("ERROR: CS did not deassert");
            errors = errors + 1;
        end
        else begin
            $display("PASS: CS deasserted");
        end

        if (done !== 1'b1) begin
            $display("ERROR: DONE not asserted");
            errors = errors + 1;
        end
        else begin
            $display("PASS: DONE asserted");
        end

        // ------------------------------------------------
        // Final result
        // ------------------------------------------------

        if (errors == 0) begin
            $display("--------------------------------");
            $display("SPI MASTER TEST PASSED");
            $display("--------------------------------");
        end
        else begin
            $display("--------------------------------");
            $display("SPI MASTER TEST FAILED: %0d errors", errors);
            $display("--------------------------------");
        end

        $finish;

    end

endmodule