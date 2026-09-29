`timescale 1ns/1ps

module apb_interface_tb;

    reg        pclk;
    reg        presetn;

    reg [7:0]  paddr;
    reg        psel;
    reg        penable;
    reg        pwrite;
    reg [31:0] pwdata;

    wire [31:0] prdata;
    wire        pready;
    wire        pslverr;

    integer errors;

    apb_interface uut (
        .pclk    (pclk),
        .presetn (presetn),
        .paddr   (paddr),
        .psel    (psel),
        .penable (penable),
        .pwrite  (pwrite),
        .pwdata  (pwdata),
        .prdata  (prdata),
        .pready  (pready),
        .pslverr (pslverr)
    );

    always #5 pclk = ~pclk;

    initial begin

        $dumpfile("sim/waves/apb_interface.vcd");
        $dumpvars(0, apb_interface_tb);

        pclk    = 1'b0;
        presetn = 1'b0;

        paddr   = 8'b0;
        psel    = 1'b0;
        penable = 1'b0;
        pwrite  = 1'b0;
        pwdata  = 32'b0;

        errors = 0;

        // ------------------------------------------------
        // Reset
        // ------------------------------------------------

        @(posedge pclk);
        #1;

        presetn = 1'b1;

        if (pready !== 1'b1) begin
            $display("ERROR: PREADY should be HIGH");
            errors = errors + 1;
        end
        else begin
            $display("PASS: PREADY is HIGH");
        end

        if (pslverr !== 1'b0) begin
            $display("ERROR: PSLVERR should be LOW");
            errors = errors + 1;
        end

        // ------------------------------------------------
        // APB WRITE
        // Address 0x00
        // ------------------------------------------------

        paddr   = 8'h00;
        pwdata  = 32'hA5A5_1234;
        pwrite  = 1'b1;
        psel    = 1'b1;

        // APB setup phase
        @(posedge pclk);
        #1;

        // APB access phase
        penable = 1'b1;

        @(posedge pclk);
        #1;

        psel    = 1'b0;
        penable = 1'b0;
        pwrite  = 1'b0;

        $display("PASS: APB write transaction completed");

        // ------------------------------------------------
        // APB READ
        // Address 0x00
        // ------------------------------------------------

        paddr   = 8'h00;
        pwrite  = 1'b0;
        psel    = 1'b1;

        // Setup phase
        @(posedge pclk);
        #1;

        // Access phase
        penable = 1'b1;

        @(posedge pclk);
        #1;

        if (prdata !== 32'hA5A5_1234) begin
            $display(
                "ERROR: APB read | Expected=%h | Got=%h",
                32'hA5A5_1234,
                prdata
            );
            errors = errors + 1;
        end
        else begin
            $display("PASS: APB read returned correct data");
        end

        psel    = 1'b0;
        penable = 1'b0;

        // ------------------------------------------------
        // Second register test
        // ------------------------------------------------

        paddr  = 8'h04;
        pwdata = 32'h1234_5678;
        pwrite = 1'b1;
        psel   = 1'b1;

        @(posedge pclk);
        #1;

        penable = 1'b1;

        @(posedge pclk);
        #1;

        psel    = 1'b0;
        penable = 1'b0;
        pwrite  = 1'b0;

        // Read second register

        paddr = 8'h04;
        psel  = 1'b1;

        @(posedge pclk);
        #1;

        penable = 1'b1;

        @(posedge pclk);
        #1;

        if (prdata !== 32'h1234_5678) begin
            $display(
                "ERROR: Second APB read | Expected=%h | Got=%h",
                32'h1234_5678,
                prdata
            );
            errors = errors + 1;
        end
        else begin
            $display("PASS: Second APB register verified");
        end

        // ------------------------------------------------
        // Final result
        // ------------------------------------------------

        if (errors == 0) begin
            $display("--------------------------------");
            $display("APB INTERFACE TEST PASSED");
            $display("--------------------------------");
        end
        else begin
            $display("--------------------------------");
            $display(
                "APB INTERFACE TEST FAILED: %0d errors",
                errors
            );
            $display("--------------------------------");
        end

        $finish;

    end

endmodule