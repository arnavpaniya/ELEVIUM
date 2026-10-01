`timescale 1ns/1ps

module spi_master_top_tb;

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

    reg [7:0] slave_tx_data;
    reg [7:0] slave_rx_data;

    integer bit_count;
    integer errors;


    // ------------------------------------------------------------
    // DUT
    // ------------------------------------------------------------

    spi_master_top uut (
        .clk     (clk),
        .reset   (reset),
        .start   (start),

        .tx_data (tx_data),
        .miso    (miso),

        .mosi    (mosi),
        .sclk    (sclk),
        .cs      (cs),

        .rx_data (rx_data),
        .busy    (busy),
        .done    (done)
    );


    // ------------------------------------------------------------
    // CPU clock
    // ------------------------------------------------------------

    always #5 clk = ~clk;


    // ------------------------------------------------------------
    // Simulated SPI slave
    //
    // LSB first
    // ------------------------------------------------------------

    always @(negedge sclk) begin

        if (!cs) begin
            miso <= slave_tx_data[bit_count];
        end

    end


    // ------------------------------------------------------------
    // Slave receives MOSI
    // ------------------------------------------------------------

    always @(posedge sclk) begin

        if (!cs) begin

            slave_rx_data[bit_count] = mosi;

            if (bit_count < 7)
                bit_count = bit_count + 1;
            else
                bit_count = 0;

        end

    end


    // ------------------------------------------------------------
    // Test
    // ------------------------------------------------------------

    initial begin

        $dumpfile("sim/waves/spi_master_top.vcd");
        $dumpvars(0, spi_master_top_tb);

        clk           = 1'b0;
        reset         = 1'b1;
        start         = 1'b0;

        tx_data       = 8'b0;
        miso          = 1'b0;

        slave_tx_data = 8'b01100101;
        slave_rx_data = 8'b0;

        bit_count     = 0;
        errors        = 0;


        // --------------------------------------------------------
        // Reset
        // --------------------------------------------------------

        #20;

        reset = 1'b0;


        // --------------------------------------------------------
        // Prepare transaction
        // --------------------------------------------------------

        tx_data = 8'b10100101;

        // Preload first MISO bit
        miso = slave_tx_data[0];

        #10;

        start = 1'b1;

        @(posedge clk);
        #1;

        start = 1'b0;


        // --------------------------------------------------------
        // Check transaction started
        // --------------------------------------------------------

        if (busy !== 1'b1) begin

            $display("ERROR: SPI transaction did not start");
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


        // --------------------------------------------------------
        // Wait for transaction completion
        // --------------------------------------------------------

        wait(done == 1'b1);

        #5;


        // --------------------------------------------------------
        // Check RX
        // --------------------------------------------------------

        if (rx_data !== slave_tx_data) begin

            $display(
                "ERROR: RX DATA | Expected=%b | Got=%b",
                slave_tx_data,
                rx_data
            );

            errors = errors + 1;

        end
        else begin

            $display("PASS: Correct RX data received");

        end


        // --------------------------------------------------------
        // Check TX
        // --------------------------------------------------------

        if (slave_rx_data !== tx_data) begin

            $display(
                "ERROR: TX DATA | Expected=%b | Got=%b",
                tx_data,
                slave_rx_data
            );

            errors = errors + 1;

        end
        else begin

            $display("PASS: Correct TX data transmitted");

        end


        // --------------------------------------------------------
        // Check BUSY
        // --------------------------------------------------------

        if (busy !== 1'b0) begin

            $display("ERROR: BUSY did not deassert");
            errors = errors + 1;

        end
        else begin

            $display("PASS: BUSY deasserted");

        end


        // --------------------------------------------------------
        // Check CS
        // --------------------------------------------------------

        if (cs !== 1'b1) begin

            $display("ERROR: CS did not deassert");
            errors = errors + 1;

        end
        else begin

            $display("PASS: CS deasserted");

        end


        // --------------------------------------------------------
        // Final result
        // --------------------------------------------------------

        if (errors == 0) begin

            $display("--------------------------------");
            $display("SPI MASTER TOP TEST PASSED");
            $display("--------------------------------");

        end
        else begin

            $display("--------------------------------");
            $display(
                "SPI MASTER TOP TEST FAILED: %0d errors",
                errors
            );
            $display("--------------------------------");

        end

        $finish;

    end

endmodule