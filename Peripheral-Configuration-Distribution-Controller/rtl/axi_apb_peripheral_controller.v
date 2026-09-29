module axi_apb_peripheral_controller (
    input wire        aclk,
    input wire        aresetn,

    input wire [7:0]  awaddr,
    input wire        awvalid,
    output wire       awready,

    input wire [31:0] wdata,
    input wire [3:0]  wstrb,
    input wire        wvalid,
    output wire       wready,

    output reg [1:0]  bresp,
    output reg        bvalid,
    input wire        bready,

    input wire [7:0]  araddr,
    input wire        arvalid,
    output wire       arready,

    output reg [31:0] rdata,
    output reg [1:0]  rresp,
    output reg        rvalid,
    input wire        rready,

    input wire        miso,
    output wire       mosi,
    output wire       sclk,
    output wire       cs
);

    localparam IDLE        = 3'd0;
    localparam W_SETUP     = 3'd1;
    localparam W_ACCESS    = 3'd2;
    localparam B_RESPONSE  = 3'd3;
    localparam R_SETUP     = 3'd4;
    localparam R_ACCESS    = 3'd5;
    localparam R_RESPONSE  = 3'd6;

    reg [2:0] state;

    reg [7:0]  apb_addr;
    reg [31:0] apb_wdata;
    reg        apb_pwrite;

    wire        apb_psel;
    wire        apb_penable;

    wire [31:0] apb_rdata;
    wire        apb_pready;
    wire        apb_pslverr;

    wire busy;
    wire done;

    // AXI ready signals
    assign awready = (state == IDLE);
    assign wready  = (state == IDLE);
    assign arready = (state == IDLE);

    // APB signals
    assign apb_psel =
        (state == W_SETUP)  ||
        (state == W_ACCESS) ||
        (state == R_SETUP)  ||
        (state == R_ACCESS);

    assign apb_penable =
        (state == W_ACCESS) ||
        (state == R_ACCESS);

    // AXI/APB control state machine
    always @(posedge aclk) begin

        if (!aresetn) begin

            state      <= IDLE;

            apb_addr   <= 8'b0;
            apb_wdata  <= 32'b0;
            apb_pwrite <= 1'b0;

            bvalid     <= 1'b0;
            bresp      <= 2'b00;

            rvalid     <= 1'b0;
            rdata      <= 32'b0;
            rresp      <= 2'b00;

        end

        else begin

            case (state)

                // ------------------------------------------------
                // IDLE
                // ------------------------------------------------

                IDLE: begin

                    if (awvalid && wvalid) begin

                        apb_addr   <= awaddr;
                        apb_wdata  <= wdata;
                        apb_pwrite <= 1'b1;

                        state <= W_SETUP;

                    end

                    else if (arvalid) begin

                        apb_addr   <= araddr;
                        apb_wdata  <= 32'b0;
                        apb_pwrite <= 1'b0;

                        state <= R_SETUP;

                    end

                end


                // ------------------------------------------------
                // APB WRITE SETUP
                // ------------------------------------------------

                W_SETUP: begin
                    state <= W_ACCESS;
                end


                // ------------------------------------------------
                // APB WRITE ACCESS
                // ------------------------------------------------

                W_ACCESS: begin

                    if (apb_pready) begin

                        if (apb_pslverr)
                            bresp <= 2'b10;
                        else
                            bresp <= 2'b00;

                        bvalid <= 1'b1;

                        state <= B_RESPONSE;

                    end

                end


                // ------------------------------------------------
                // AXI WRITE RESPONSE
                // ------------------------------------------------

                B_RESPONSE: begin

                    if (bready) begin

                        bvalid <= 1'b0;

                        state <= IDLE;

                    end

                end


                // ------------------------------------------------
                // APB READ SETUP
                // ------------------------------------------------

                R_SETUP: begin
                    state <= R_ACCESS;
                end


                // ------------------------------------------------
                // APB READ ACCESS
                // ------------------------------------------------

                R_ACCESS: begin

                    if (apb_pready) begin

                        rdata <= apb_rdata;

                        if (apb_pslverr)
                            rresp <= 2'b10;
                        else
                            rresp <= 2'b00;

                        rvalid <= 1'b1;

                        state <= R_RESPONSE;

                    end

                end


                // ------------------------------------------------
                // AXI READ RESPONSE
                // ------------------------------------------------

                R_RESPONSE: begin

                    if (rready) begin

                        rvalid <= 1'b0;

                        state <= IDLE;

                    end

                end


                default: begin
                    state <= IDLE;
                end

            endcase

        end

    end


    // ------------------------------------------------------------
    // APB SPI peripheral
    // ------------------------------------------------------------

    apb_peripheral_controller apb_spi (

        .pclk     (aclk),
        .presetn  (aresetn),

        .paddr    (apb_addr),
        .psel     (apb_psel),
        .penable  (apb_penable),
        .pwrite   (apb_pwrite),
        .pwdata   (apb_wdata),

        .prdata   (apb_rdata),
        .pready   (apb_pready),
        .pslverr  (apb_pslverr),

        .miso     (miso),
        .mosi     (mosi),
        .sclk     (sclk),
        .cs       (cs),

        .busy     (busy),
        .done     (done)
    );

endmodule