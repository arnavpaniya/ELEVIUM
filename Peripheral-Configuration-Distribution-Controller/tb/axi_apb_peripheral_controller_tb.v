`timescale 1ns/1ps

module axi_apb_peripheral_controller_tb;

    reg aclk;
    reg aresetn;

    reg [7:0]  awaddr;
    reg        awvalid;
    wire       awready;

    reg [31:0] wdata;
    reg [3:0]  wstrb;
    reg        wvalid;
    wire       wready;

    wire [1:0] bresp;
    wire       bvalid;
    reg        bready;

    reg [7:0]  araddr;
    reg        arvalid;
    wire       arready;

    wire [31:0] rdata;
    wire [1:0]  rresp;
    wire        rvalid;
    reg         rready;

    reg         miso;

    wire        mosi;
    wire        sclk;
    wire        cs;

    reg [7:0] slave_tx_data;
    reg [7:0] slave_rx_data;

    integer bit_count;
    integer errors;

    axi_apb_peripheral_controller dut (
        .aclk     (aclk),
        .aresetn  (aresetn),

        .awaddr   (awaddr),
        .awvalid  (awvalid),
        .awready  (awready),

        .wdata    (wdata),
        .wstrb    (wstrb),
        .wvalid   (wvalid),
        .wready   (wready),

        .bresp    (bresp),
        .bvalid   (bvalid),
        .bready   (bready),

        .araddr   (araddr),
        .arvalid  (arvalid),
        .arready  (arready),

        .rdata    (rdata),
        .rresp    (rresp),
        .rvalid   (rvalid),
        .rready   (rready),

        .miso     (miso),

        .mosi     (mosi),
        .sclk     (sclk),
        .cs       (cs)
    );

    // AXI clock
    always #5 aclk = ~aclk;

    // ------------------------------------------------------------
    // SPI slave model
    // LSB first
    // ------------------------------------------------------------

    always @(negedge sclk) begin
        if (!cs)
            miso <= slave_tx_data[bit_count];
    end

    always @(posedge sclk) begin
        if (!cs) begin
            slave_rx_data[7-bit_count] = mosi;

            if (bit_count < 7)
                bit_count = bit_count + 1;
            else
                bit_count = 0;
        end
    end

    // ------------------------------------------------------------
    // AXI write task
    // ------------------------------------------------------------

    task axi_write;
        input [7:0]  addr;
        input [31:0] data;

        begin
            @(posedge aclk);

            awaddr  <= addr;
            awvalid <= 1'b1;

            wdata   <= data;
            wstrb   <= 4'b1111;
            wvalid  <= 1'b1;

            wait(awready && wready);

            @(posedge aclk);

            awvalid <= 1'b0;
            wvalid  <= 1'b0;

            wait(bvalid);

            if (bresp !== 2'b00) begin
                $display("ERROR: AXI write response");
                errors = errors + 1;
            end
            else begin
                $display("PASS: AXI write response");
            end

            bready <= 1'b1;

            @(posedge aclk);

            bready <= 1'b0;
        end
    endtask

    // ------------------------------------------------------------
    // AXI read task
    // ------------------------------------------------------------

    task axi_read;
        input [7:0] addr;

        begin
            @(posedge aclk);

            araddr  <= addr;
            arvalid <= 1'b1;

            wait(arready);

            @(posedge aclk);

            arvalid <= 1'b0;

            wait(rvalid);

            if (rresp !== 2'b00) begin
                $display("ERROR: AXI read response");
                errors = errors + 1;
            end
            else begin
                $display("PASS: AXI read response");
            end

            rready <= 1'b1;

            @(posedge aclk);

            rready <= 1'b0;
        end
    endtask

    // ------------------------------------------------------------
    // Test
    // ------------------------------------------------------------

    initial begin

        $dumpfile("sim/waves/axi_apb_peripheral_controller.vcd");
        $dumpvars(0, axi_apb_peripheral_controller_tb);

        aclk    = 1'b0;
        aresetn = 1'b0;

        awaddr  = 8'b0;
        awvalid = 1'b0;

        wdata   = 32'b0;
        wstrb   = 4'b1111;
        wvalid  = 1'b0;

        bready  = 1'b0;

        araddr  = 8'b0;
        arvalid = 1'b0;

        rready  = 1'b0;

        slave_tx_data = 8'h65;
        slave_rx_data = 8'b0;

        bit_count = 0;
        errors    = 0;

        // IMPORTANT:
        // First MISO bit must already be available before
        // the first SPI rising edge.
        miso = slave_tx_data[0];

        #20;

        aresetn = 1'b1;

        // -----------------------------------------------
        // Write TX register through AXI
        // -----------------------------------------------

        axi_write(8'h00, 32'h000000A5);

        $display("PASS: TX register written through AXI");

        // -----------------------------------------------
        // Read TX register through AXI
        // -----------------------------------------------

        axi_read(8'h00);

        if (rdata !== 32'h000000A5) begin

            $display(
                "ERROR: TX readback | Expected=%h | Got=%h",
                32'h000000A5,
                rdata
            );

            errors = errors + 1;

        end
        else begin

            $display("PASS: TX register read through AXI");

        end

        // -----------------------------------------------
        // Start SPI through AXI
        // -----------------------------------------------

        axi_write(8'h04, 32'h00000001);

        wait(cs == 1'b0);

        $display("PASS: SPI transaction started through AXI");

        wait(cs == 1'b1);

        // -----------------------------------------------
        // Verify SPI TX
        // -----------------------------------------------

        if (slave_rx_data !== 8'hA5) begin

            $display(
                "ERROR: SPI TX | Expected=%h | Got=%h",
                8'hA5,
                slave_rx_data
            );

            errors = errors + 1;

        end
        else begin

            $display("PASS: SPI TX through AXI -> APB");

        end

        // -----------------------------------------------
        // Read RX register through AXI
        // -----------------------------------------------

        axi_read(8'h08);

        if (rdata[7:0] !== slave_tx_data) begin

            $display(
                "ERROR: SPI RX | Expected=%h | Got=%h",
                slave_tx_data,
                rdata[7:0]
            );

            errors = errors + 1;

        end
        else begin

            $display("PASS: SPI RX through AXI -> APB");

        end

        // -----------------------------------------------
        // Final result
        // -----------------------------------------------

        if (errors == 0) begin

            $display("--------------------------------");
            $display("AXI APB PERIPHERAL CONTROLLER TEST PASSED");
            $display("--------------------------------");

        end
        else begin

            $display("--------------------------------");
            $display(
                "AXI APB PERIPHERAL CONTROLLER TEST FAILED: %0d errors",
                errors
            );
            $display("--------------------------------");

        end

        $finish;

    end

endmodule