module spi_master (
    input  wire       clk,
    input  wire       reset,

    input  wire       start,
    input  wire [7:0] tx_data,
    input  wire       miso,

    output reg        mosi,
    output reg        sclk,
    output reg        cs,

    output reg [7:0]  rx_data,
    output reg        busy,
    output reg        done
);

    reg [7:0] tx_shift;
    reg [7:0] rx_shift;
    reg [2:0] bit_count;

    always @(posedge clk) begin

        if (reset) begin
            tx_shift <= 8'b0;
            rx_shift <= 8'b0;
            rx_data  <= 8'b0;

            bit_count <= 3'b0;

            mosi <= 1'b0;
            sclk <= 1'b0;
            cs   <= 1'b1;

            busy <= 1'b0;
            done <= 1'b0;
        end

        else begin

            done <= 1'b0;

            // Start a new transaction
            if (start && !busy) begin

                tx_shift <= tx_data;
                rx_shift <= 8'b0;

                bit_count <= 3'd0;

                // Send first LSB
                mosi <= tx_data[0];

                cs   <= 1'b0;
                sclk <= 1'b0;

                busy <= 1'b1;
            end

            else if (busy) begin

                // Toggle SPI clock
                sclk <= ~sclk;

                // Rising edge: sample MISO
                if (sclk == 1'b0) begin

                    rx_shift <= {miso, rx_shift[7:1]};

                end

                // Falling edge: prepare next MOSI bit
                else begin

                    if (bit_count == 3'd7) begin

                        // Include the final sampled MISO bit
                        rx_data <= {miso, rx_shift[7:1]};

                        cs   <= 1'b1;
                        sclk <= 1'b0;

                        busy <= 1'b0;
                        done <= 1'b1;

                        mosi <= 1'b0;

                    end

                    else begin

                        bit_count <= bit_count + 1'b1;

                        tx_shift <= tx_shift >> 1;

                        mosi <= tx_shift[1];

                    end

                end

            end

        end

    end

endmodule