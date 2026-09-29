module fifo #(
    parameter DATA_WIDTH = 8,
    parameter DEPTH = 16
)(
    input  wire                  clk,
    input  wire                  reset,

    input  wire                  write_en,
    input  wire [DATA_WIDTH-1:0] write_data,

    input  wire                  read_en,
    output reg  [DATA_WIDTH-1:0] read_data,

    output wire                  full,
    output wire                  empty
);

    reg [DATA_WIDTH-1:0] memory [0:DEPTH-1];

    reg [4:0] write_ptr;
    reg [4:0] read_ptr;
    reg [4:0] count;

    assign full  = (count == DEPTH);
    assign empty = (count == 0);

    always @(posedge clk) begin

        if (reset) begin
            write_ptr <= 5'd0;
            read_ptr  <= 5'd0;
            count     <= 5'd0;
            read_data <= {DATA_WIDTH{1'b0}};
        end

        else begin

            if (write_en && !full) begin
                memory[write_ptr[3:0]] <= write_data;
                write_ptr <= write_ptr + 1'b1;
            end

            if (read_en && !empty) begin
                read_data <= memory[read_ptr[3:0]];
                read_ptr <= read_ptr + 1'b1;
            end

            case ({write_en && !full, read_en && !empty})

                2'b10: count <= count + 1'b1;

                2'b01: count <= count - 1'b1;

                default: count <= count;

            endcase
        end
    end

endmodule