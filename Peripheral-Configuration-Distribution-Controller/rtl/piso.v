module piso (
    input wire       clk,
    input wire       reset,
    input wire       load,
    input wire       enable,

    input wire [7:0] parallel_in,

    output reg       serial_out,
    output reg       valid
);

    reg [7:0] shift_reg;
    reg [2:0] bit_count;

    always @(posedge clk) begin

        if (reset) begin
            shift_reg  <= 8'b0;
            bit_count  <= 3'b0;
            serial_out <= 1'b0;
            valid      <= 1'b0;
        end

        else begin
            valid <= 1'b0;

            // Load parallel data
            if (load) begin
                shift_reg  <= parallel_in;
                bit_count  <= 3'b0;
                serial_out <= parallel_in[0];
            end

            // Shift only when enabled
            else if (enable) begin

                if (bit_count < 3'd7) begin
                    shift_reg  <= shift_reg >> 1;
                    bit_count  <= bit_count + 1'b1;
                    serial_out <= shift_reg[1];
                end

                else begin
                    shift_reg  <= shift_reg >> 1;
                    bit_count  <= 3'b0;
                    serial_out <= shift_reg[7];
                    valid      <= 1'b1;
                end

            end
        end
    end

endmodule