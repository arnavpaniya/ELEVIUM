module apb_peripheral_controller (
    input  wire        pclk,
    input  wire        presetn,

    input  wire [7:0]  paddr,
    input  wire        psel,
    input  wire        penable,
    input  wire        pwrite,
    input  wire [31:0] pwdata,

    output wire [31:0] prdata,
    output wire        pready,
    output wire        pslverr,

    input  wire        miso,

    output wire        mosi,
    output wire        sclk,
    output wire        cs,

    output wire        busy,
    output wire        done
);

    reg [31:0] tx_register;
    reg        start_pulse;

    wire [7:0] rx_data;

    wire apb_write;

    assign apb_write = psel && penable && pwrite;

    assign pready  = 1'b1;
    assign pslverr = 1'b0;

    assign prdata =
        (paddr[3:2] == 2'b00) ? tx_register :
        (paddr[3:2] == 2'b01) ? {31'b0, busy} :
        (paddr[3:2] == 2'b10) ? {24'b0, rx_data} :
        (paddr[3:2] == 2'b11) ? {30'b0, done, busy} :
        32'b0;

    always @(posedge pclk) begin

        if (!presetn) begin
            tx_register <= 32'b0;
            start_pulse <= 1'b0;
        end

        else begin

            start_pulse <= 1'b0;

            if (apb_write) begin

                case (paddr[3:2])

                    2'b00: begin
                        tx_register <= pwdata;
                    end

                    2'b01: begin
                        if (pwdata[0])
                            start_pulse <= 1'b1;
                    end

                    default: begin
                    end

                endcase

            end

        end

    end

    peripheral_controller spi_controller (
        .clk     (pclk),
        .reset   (!presetn),

        .start   (start_pulse),
        .tx_data (tx_register[7:0]),
        .miso    (miso),

        .mosi    (mosi),
        .sclk    (sclk),
        .cs      (cs),

        .rx_data (rx_data),
        .busy    (busy),
        .done    (done)
    );

endmodule