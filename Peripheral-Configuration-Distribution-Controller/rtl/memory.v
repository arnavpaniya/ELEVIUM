module memory #(
    parameter DATA_WIDTH = 8,
    parameter ADDR_WIDTH = 4
)(
    input  wire                  clk,
    input  wire                  reset,

    input  wire                  write_en,
    input  wire [ADDR_WIDTH-1:0] address,
    input  wire [DATA_WIDTH-1:0] write_data,

    output reg  [DATA_WIDTH-1:0] read_data
);

    reg [DATA_WIDTH-1:0] mem [0:(1 << ADDR_WIDTH)-1];

    integer i;

    always @(posedge clk) begin

        if (reset) begin
            read_data <= {DATA_WIDTH{1'b0}};

            for (i = 0; i < (1 << ADDR_WIDTH); i = i + 1)
                mem[i] <= {DATA_WIDTH{1'b0}};
        end

        else begin

            if (write_en)
                mem[address] <= write_data;

            read_data <= mem[address];

        end

    end

endmodule
