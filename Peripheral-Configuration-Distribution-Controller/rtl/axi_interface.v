module axi_interface #(
    parameter ADDR_WIDTH = 8,
    parameter DATA_WIDTH = 32
)(
    input  wire                  aclk,
    input  wire                  aresetn,

    input  wire [ADDR_WIDTH-1:0] awaddr,
    input  wire                  awvalid,
    output wire                  awready,

    input  wire [DATA_WIDTH-1:0] wdata,
    input  wire [3:0]            wstrb,
    input  wire                  wvalid,
    output wire                  wready,

    output reg  [1:0]            bresp,
    output reg                   bvalid,
    input  wire                   bready,

    input  wire [ADDR_WIDTH-1:0] araddr,
    input  wire                  arvalid,
    output wire                  arready,

    output reg  [DATA_WIDTH-1:0] rdata,
    output reg  [1:0]            rresp,
    output reg                   rvalid,
    input  wire                   rready
);

    reg [DATA_WIDTH-1:0] memory [0:3];

    assign awready = 1'b1;
    assign wready  = 1'b1;
    assign arready = 1'b1;

    always @(posedge aclk) begin

        if (!aresetn) begin

            bvalid <= 1'b0;
            bresp  <= 2'b00;

            rvalid <= 1'b0;
            rresp  <= 2'b00;
            rdata  <= {DATA_WIDTH{1'b0}};

        end

        else begin

            if (awvalid && wvalid) begin

                memory[awaddr[3:2]] <= wdata;

                bvalid <= 1'b1;
                bresp  <= 2'b00;

            end

            if (bvalid && bready)
                bvalid <= 1'b0;

            if (arvalid) begin

                rdata <= memory[araddr[3:2]];

                rvalid <= 1'b1;
                rresp  <= 2'b00;

            end

            if (rvalid && rready)
                rvalid <= 1'b0;

        end

    end

endmodule