`timescale 1ns/1ps

module axi_interface_tb;

    reg aclk;
    reg aresetn;

    reg  [7:0]  awaddr;
    reg         awvalid;
    wire        awready;

    reg  [31:0] wdata;
    reg  [3:0]  wstrb;
    reg         wvalid;
    wire        wready;

    wire [1:0]  bresp;
    wire        bvalid;
    reg         bready;

    reg  [7:0]  araddr;
    reg         arvalid;
    wire        arready;

    wire [31:0] rdata;
    wire [1:0]  rresp;
    wire        rvalid;
    reg         rready;

    integer errors;

    axi_interface uut (
        .aclk    (aclk),
        .aresetn (aresetn),

        .awaddr  (awaddr),
        .awvalid (awvalid),
        .awready (awready),

        .wdata   (wdata),
        .wstrb   (wstrb),
        .wvalid  (wvalid),
        .wready  (wready),

        .bresp   (bresp),
        .bvalid  (bvalid),
        .bready  (bready),

        .araddr  (araddr),
        .arvalid (arvalid),
        .arready (arready),

        .rdata   (rdata),
        .rresp   (rresp),
        .rvalid  (rvalid),
        .rready  (rready)
    );

    always #5 aclk = ~aclk;

    initial begin

        $dumpfile("sim/waves/axi_interface.vcd");
        $dumpvars(0, axi_interface_tb);

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

        errors = 0;

        // ------------------------------------------------
        // RESET
        // ------------------------------------------------

        @(posedge aclk);
        #1;

        aresetn = 1'b1;

        // ------------------------------------------------
        // Check READY signals
        // ------------------------------------------------

        if (awready !== 1'b1) begin
            $display("ERROR: AWREADY should be HIGH");
            errors = errors + 1;
        end
        else begin
            $display("PASS: AWREADY is HIGH");
        end

        if (wready !== 1'b1) begin
            $display("ERROR: WREADY should be HIGH");
            errors = errors + 1;
        end
        else begin
            $display("PASS: WREADY is HIGH");
        end

        if (arready !== 1'b1) begin
            $display("ERROR: ARREADY should be HIGH");
            errors = errors + 1;
        end
        else begin
            $display("PASS: ARREADY is HIGH");
        end

        // ------------------------------------------------
        // AXI WRITE TRANSACTION
        // Address = 0x00
        // Data    = A5A51234
        // ------------------------------------------------

        awaddr  = 8'h00;
        awvalid = 1'b1;

        wdata   = 32'hA5A5_1234;
        wstrb   = 4'b1111;
        wvalid  = 1'b1;

        @(posedge aclk);
        #1;

        if (bvalid !== 1'b1) begin
            $display("ERROR: BVALID not asserted after write");
            errors = errors + 1;
        end
        else begin
            $display("PASS: AXI write response generated");
        end

        if (bresp !== 2'b00) begin
            $display("ERROR: BRESP should indicate OKAY");
            errors = errors + 1;
        end
        else begin
            $display("PASS: BRESP = OKAY");
        end

        awvalid = 1'b0;
        wvalid  = 1'b0;

        // Accept write response

        bready = 1'b1;

        @(posedge aclk);
        #1;

        bready = 1'b0;

        if (bvalid !== 1'b0) begin
            $display("ERROR: BVALID did not clear");
            errors = errors + 1;
        end
        else begin
            $display("PASS: Write response handshake completed");
        end

        // ------------------------------------------------
        // AXI READ TRANSACTION
        // Address = 0x00
        // ------------------------------------------------

        araddr  = 8'h00;
        arvalid = 1'b1;

        @(posedge aclk);
        #1;

        if (rvalid !== 1'b1) begin
            $display("ERROR: RVALID not asserted after read");
            errors = errors + 1;
        end
        else begin
            $display("PASS: AXI read response generated");
        end

        if (rdata !== 32'hA5A5_1234) begin
            $display(
                "ERROR: Read data mismatch | Expected=%h | Got=%h",
                32'hA5A5_1234,
                rdata
            );
            errors = errors + 1;
        end
        else begin
            $display("PASS: Correct data returned from AXI read");
        end

        if (rresp !== 2'b00) begin
            $display("ERROR: RRESP should indicate OKAY");
            errors = errors + 1;
        end
        else begin
            $display("PASS: RRESP = OKAY");
        end

        arvalid = 1'b0;

        // Accept read response

        rready = 1'b1;

        @(posedge aclk);
        #1;

        rready = 1'b0;

        if (rvalid !== 1'b0) begin
            $display("ERROR: RVALID did not clear");
            errors = errors + 1;
        end
        else begin
            $display("PASS: Read response handshake completed");
        end

        // ------------------------------------------------
        // Final result
        // ------------------------------------------------

        if (errors == 0) begin
            $display("--------------------------------");
            $display("AXI INTERFACE TEST PASSED");
            $display("--------------------------------");
        end
        else begin
            $display("--------------------------------");
            $display(
                "AXI INTERFACE TEST FAILED: %0d errors",
                errors
            );
            $display("--------------------------------");
        end

        $finish;

    end

endmodule