module cdc (
    input  wire clk,
    input  wire reset,
    input  wire async_in,
    output reg  sync_out
);

    reg sync_ff1;

    always @(posedge clk) begin

        if (reset) begin
            sync_ff1 <= 1'b0;
            sync_out <= 1'b0;
        end

        else begin
            sync_ff1 <= async_in;
            sync_out <= sync_ff1;
        end

    end

endmodule