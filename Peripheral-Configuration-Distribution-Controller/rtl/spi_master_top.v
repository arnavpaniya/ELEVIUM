module spi_master_top (
    input wire        clk,
    input wire        reset,
    input wire        start,
    input wire [7:0]  tx_data,
    input wire        miso,

    output wire       mosi,
    output reg        sclk,
    output wire       cs,
    output wire [7:0] rx_data,
    output wire       busy,
    output wire       done
);

    // ============================================================
    // Internal signals
    // ============================================================

    wire spi_clk;

    wire piso_serial;
    wire piso_valid;

    wire [7:0] sipo_parallel;
    wire       sipo_valid;

    reg piso_load;
    reg piso_enable;
    reg sipo_enable;

    reg [2:0] bit_count;

    reg active;
    reg done_reg;

    reg spi_clk_prev;

    // First rising edge must occur before PISO is shifted.
    reg first_sample_done;

    // ============================================================
    // Clock divider
    // ============================================================

    clock_divider clk_div (
        .clk(clk),
        .reset(reset),
        .clk_out(spi_clk)
    );

    // ============================================================
    // PISO
    // ============================================================

    piso tx_piso (
        .clk(clk),
        .reset(reset),
        .load(piso_load),
        .enable(piso_enable),
        .parallel_in(tx_data),
        .serial_out(piso_serial),
        .valid(piso_valid)
    );

    // ============================================================
    // SIPO
    // ============================================================

    sipo rx_sipo (
        .clk(clk),
        .reset(reset),
        .enable(sipo_enable),
        .serial_in(miso),
        .parallel_out(sipo_parallel),
        .valid(sipo_valid)
    );

    // ============================================================
    // Outputs
    // ============================================================

    assign mosi    = piso_serial;
    assign rx_data = sipo_parallel;

    assign busy = active;
    assign cs   = ~active;
    assign done = done_reg;

    // ============================================================
    // SPI controller
    // ============================================================

    always @(posedge clk) begin

        if (reset) begin

            piso_load       <= 1'b0;
            piso_enable     <= 1'b0;
            sipo_enable     <= 1'b0;

            bit_count       <= 3'd0;

            active          <= 1'b0;
            done_reg        <= 1'b0;

            spi_clk_prev    <= 1'b0;
            first_sample_done <= 1'b0;

            sclk            <= 1'b0;

        end

        else begin

            // ----------------------------------------------------
            // Default pulse signals
            // ----------------------------------------------------

            piso_load   <= 1'b0;
            piso_enable <= 1'b0;
            sipo_enable <= 1'b0;

            done_reg <= 1'b0;

            // ----------------------------------------------------
            // Start transaction
            // ----------------------------------------------------

            if (start && !active) begin

                // Load TX data into PISO.
                piso_load <= 1'b1;

                bit_count <= 3'd0;

                active <= 1'b1;

                sclk <= 1'b0;

                /*
                 * Synchronize the divider edge detector with its
                 * current state.
                 */
                spi_clk_prev <= spi_clk;

                /*
                 * Most important part:
                 * do not shift PISO until the first rising edge
                 * has sampled bit 0.
                 */
                first_sample_done <= 1'b0;

            end

            // ----------------------------------------------------
            // Active SPI transaction
            // ----------------------------------------------------

            else if (active) begin

                // Detect divider clock transition.
                if (spi_clk != spi_clk_prev) begin

                    // =================================================
                    // RISING EDGE
                    // =================================================

                    if (spi_clk == 1'b1) begin

                        /*
                         * Sample MISO.
                         *
                         * This is always the first SPI operation.
                         * Therefore PISO bit 0 cannot be lost.
                         */
                        sipo_enable <= 1'b1;

                        sclk <= 1'b1;

                        first_sample_done <= 1'b1;

                    end

                    // =================================================
                    // FALLING EDGE
                    // =================================================

                    else begin

                        sclk <= 1'b0;

                        /*
                         * Never shift before the first rising edge.
                         */
                        if (first_sample_done) begin

                            if (bit_count == 3'd7) begin

                                // Eight bits completed.
                                active   <= 1'b0;
                                done_reg <= 1'b1;

                            end

                            else begin

                                // Prepare next TX bit.
                                piso_enable <= 1'b1;

                                bit_count <= bit_count + 1'b1;

                            end

                        end

                    end

                end

                // Update divider history.
                spi_clk_prev <= spi_clk;

            end

            else begin

                sclk <= 1'b0;

            end

        end

    end

endmodule