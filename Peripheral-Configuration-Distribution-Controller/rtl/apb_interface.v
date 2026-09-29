module apb_interface #(
    parameter DATA_WIDTH = 32,
    parameter ADDR_WIDTH = 8
)(
    input  wire                  pclk,
    input  wire                  presetn,

    input  wire [ADDR_WIDTH-1:0] paddr,
    input  wire                  psel,
    input  wire                  penable,
    input  wire                  pwrite,

    input  wire [DATA_WIDTH-1:0] pwdata,

    output reg  [DATA_WIDTH-1:0] prdata,
    output wire                  pready,
    output wire                  pslverr
);

    reg [DATA_WIDTH-1:0] registers [0:3];

    assign pready  = 1'b1;
    assign pslverr = 1'b0;

    always @(posedge pclk) begin

        if (!presetn) begin

            prdata <= {DATA_WIDTH{1'b0}};

            registers[0] <= {DATA_WIDTH{1'b0}};
            registers[1] <= {DATA_WIDTH{1'b0}};
            registers[2] <= {DATA_WIDTH{1'b0}};
            registers[3] <= {DATA_WIDTH{1'b0}};

        end

        else if (psel && penable) begin

            if (pwrite) begin

                case (paddr[3:2])

                    2'b00: registers[0] <= pwdata;
                    2'b01: registers[1] <= pwdata;
                    2'b10: registers[2] <= pwdata;
                    2'b11: registers[3] <= pwdata;

                endcase

            end

            else begin

                case (paddr[3:2])

                    2'b00: prdata <= registers[0];
                    2'b01: prdata <= registers[1];
                    2'b10: prdata <= registers[2];
                    2'b11: prdata <= registers[3];

                endcase

            end

        end

    end

endmodule