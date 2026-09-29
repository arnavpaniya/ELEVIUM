module peripheral_controller (
    input  wire       clk,
    input  wire       reset,
    input  wire       start,
    input  wire [7:0] tx_data,
    input  wire       miso,

    output reg       mosi,
    output reg       sclk,
    output reg       cs,

    output reg [7:0] rx_data,
    output reg       busy,
    output reg       done
);

    reg [7:0] tx_shift;
    reg [7:0] rx_shift;
    reg [3:0] bit_count;

    wire spi_clk;

    // --------------------------------------------------
    // SPI clock divider
    // CPU clock -> SPI clock /4
    // --------------------------------------------------

    clock_divider clk_div (
        .clk     (clk),
        .reset   (reset),
        .clk_out (spi_clk)
    );

    // --------------------------------------------------
    // SPI controller
    // --------------------------------------------------

    always @(posedge clk) begin

        if (reset) begin

            tx_shift  <= 8'b0;
            rx_shift  <= 8'b0;
            bit_count <= 4'd0;

            mosi <= 1'b0;
            sclk <= 1'b0;
            cs   <= 1'b1;

            rx_data <= 8'b0;
            busy    <= 1'b0;
            done    <= 1'b0;

        end else begin

            done <= 1'b0;

            // ------------------------------------------
            // Start transaction
            // ------------------------------------------

            if (start && !busy) begin

                tx_shift  <= tx_data;
                rx_shift  <= 8'b0;
                bit_count <= 4'd0;

                mosi <= tx_data[7];
                sclk <= 1'b0;
                cs   <= 1'b0;

                busy <= 1'b1;

            end

            // ------------------------------------------
            // SPI transaction
            // ------------------------------------------

            else if (busy && spi_clk) begin

                // --------------------------------------
                // Rising SPI edge
                // Sample MISO
                // --------------------------------------

                if (sclk == 1'b0) begin

                    sclk <= 1'b1;

                    rx_shift <= {
                        rx_shift[6:0],
                        miso
                    };

                end

                // --------------------------------------
                // Falling SPI edge
                // Shift TX
                // --------------------------------------

                else begin

                    sclk <= 1'b0;

                    if (bit_count == 4'd7) begin

                        rx_data <= rx_shift;

                        mosi <= 1'b0;
                        cs   <= 1'b1;

                        busy <= 1'b0;
                        done <= 1'b1;

                    end else begin

                        bit_count <= bit_count + 1'b1;

                        tx_shift <= {
                            tx_shift[6:0],
                            1'b0
                        };

                        mosi <= tx_shift[6];

                    end

                end

            end

        end

    end

endmodule