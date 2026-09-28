module sipo (
    input  wire       clk,
    input  wire       reset,
    input  wire       enable,
    input  wire       serial_in,
    output reg  [7:0] parallel_out,
    output reg        valid
);

    reg [7:0] shift_reg;
    reg [2:0] bit_count;

    always @(posedge clk) begin

        if (reset) begin
            shift_reg   <= 8'b0;
            parallel_out <= 8'b0;
            bit_count   <= 3'b0;
            valid       <= 1'b0;
        end

        else begin

            valid <= 1'b0;

            if (enable) begin

                if (bit_count < 3'd7) begin
                    shift_reg <= {serial_in, shift_reg[7:1]};
                    bit_count <= bit_count + 1'b1;
                end

                else begin
                    shift_reg <= {serial_in, shift_reg[7:1]};

                    parallel_out <= {serial_in, shift_reg[7:1]};

                    bit_count <= 3'b0;
                    valid <= 1'b1;
                end

            end

        end

    end

endmodule