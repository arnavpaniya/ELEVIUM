module clock_divider (
    input  wire clk,
    input  wire reset,
    output reg  clk_out
);

    reg [1:0] count;

    always @(posedge clk) begin

        if (reset) begin
            count   <= 2'b00;
            clk_out <= 1'b0;
        end

        else begin

            if (count == 2'd1) begin
                count   <= 2'b00;
                clk_out <= ~clk_out;
            end

            else begin
                count <= count + 1'b1;
            end

        end

    end

endmodule