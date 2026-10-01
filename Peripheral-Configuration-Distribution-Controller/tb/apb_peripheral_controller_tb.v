`timescale 1ns/1ps

module apb_peripheral_controller_tb;

    reg pclk;
    reg presetn;

    reg [7:0]  paddr;
    reg        psel;
    reg        penable;
    reg        pwrite;
    reg [31:0] pwdata;

    wire [31:0] prdata;
    wire        pready;
    wire        pslverr;

    reg         miso;
    wire        mosi;
    wire        sclk;
    wire        cs;
    wire        busy;
    wire        done;

    reg [7:0] slave_tx_data;
    reg [7:0] slave_rx_data;

    integer bit_count;
    integer errors;

    reg [31:0] read_data;

    // ============================================================
    // DUT
    // ============================================================

    apb_peripheral_controller dut (
        .pclk(pclk),
        .presetn(presetn),
        .paddr(paddr),
        .psel(psel),
        .penable(penable),
        .pwrite(pwrite),
        .pwdata(pwdata),
        .prdata(prdata),
        .pready(pready),
        .pslverr(pslverr),
        .miso(miso),
        .mosi(mosi),
        .sclk(sclk),
        .cs(cs),
        .busy(busy),
        .done(done)
    );

    // ============================================================
    // CLOCK
    // ============================================================

    always #5 pclk = ~pclk;

    // ============================================================
    // SPI SLAVE MODEL
    // LSB FIRST
    //
    // MISO is changed on falling edge.
    // MOSI is sampled slightly after rising edge to avoid
    // simulator race conditions.
    // ============================================================

    always @(negedge sclk) begin
        if (!cs) begin
            #1;
            miso <= slave_tx_data[bit_count];
        end
    end

    always @(posedge sclk) begin
        if (!cs) begin
            #1;

            slave_rx_data[bit_count] = mosi;

            if (bit_count < 7)
                bit_count = bit_count + 1;
            else
                bit_count = 0;
        end
    end

    // ============================================================
    // APB WRITE
    // ============================================================

    task apb_write;
        input [7:0]  addr;
        input [31:0] data;

        begin
            // SETUP
            @(posedge pclk);

            paddr   <= addr;
            pwdata  <= data;
            pwrite  <= 1'b1;
            psel    <= 1'b1;
            penable <= 1'b0;

            // ACCESS
            @(posedge pclk);

            penable <= 1'b1;

            // COMPLETE
            @(posedge pclk);

            psel    <= 1'b0;
            penable <= 1'b0;
            pwrite  <= 1'b0;
            paddr   <= 8'b0;
            pwdata  <= 32'b0;
        end
    endtask

    // ============================================================
    // APB READ
    // ============================================================

    task apb_read;
        input  [7:0] addr;
        output [31:0] data;

        begin
            // SETUP
            @(posedge pclk);

            paddr   <= addr;
            pwrite  <= 1'b0;
            psel    <= 1'b1;
            penable <= 1'b0;

            // ACCESS
            @(posedge pclk);

            penable <= 1'b1;

            #1;
            data = prdata;

            // COMPLETE
            @(posedge pclk);

            psel    <= 1'b0;
            penable <= 1'b0;
            paddr   <= 8'b0;
        end
    endtask

    // ============================================================
    // TEST
    // ============================================================

    initial begin

        $dumpfile("sim/waves/apb_peripheral_controller.vcd");
        $dumpvars(0, apb_peripheral_controller_tb);

        // --------------------------------------------------------
        // INITIALIZE
        // --------------------------------------------------------

        pclk          = 1'b0;
        presetn       = 1'b0;

        paddr         = 8'b0;
        psel          = 1'b0;
        penable       = 1'b0;
        pwrite        = 1'b0;
        pwdata        = 32'b0;

        slave_tx_data = 8'h65;
        slave_rx_data = 8'h00;

        bit_count     = 0;
        errors        = 0;

        // First MISO bit must already be present.
        miso = slave_tx_data[0];

        // --------------------------------------------------------
        // RESET
        // --------------------------------------------------------

        #20;

        presetn = 1'b1;

        #10;

        // --------------------------------------------------------
        // PREADY
        // --------------------------------------------------------

        if (pready === 1'b1)
            $display("PASS: PREADY");
        else begin
            $display("ERROR: PREADY");
            errors = errors + 1;
        end

        // --------------------------------------------------------
        // PSLVERR
        // --------------------------------------------------------

        if (pslverr === 1'b0)
            $display("PASS: PSLVERR");
        else begin
            $display("ERROR: PSLVERR");
            errors = errors + 1;
        end

        // --------------------------------------------------------
        // WRITE TX REGISTER
        // Address = 0x00
        // Data = A5
        // --------------------------------------------------------

        apb_write(8'h00, 32'h000000A5);

        // --------------------------------------------------------
        // READ TX REGISTER
        // --------------------------------------------------------

        apb_read(8'h00, read_data);

        if (read_data === 32'h000000A5)
            $display("PASS: TX register readback");
        else begin
            $display(
                "ERROR: TX register readback | Expected=A5 | Got=%h",
                read_data
            );
            errors = errors + 1;
        end

        // --------------------------------------------------------
        // RESET SPI SLAVE STATE
        // --------------------------------------------------------

        slave_rx_data = 8'h00;
        bit_count     = 0;

        // First received MISO bit
        miso = slave_tx_data[0];

        // --------------------------------------------------------
        // START SPI
        // Address = 0x04
        // --------------------------------------------------------

        apb_write(8'h04, 32'h00000001);

        // Allow start pulse to propagate
        @(posedge pclk);
        #1;

        if (busy === 1'b1)
            $display("PASS: SPI transaction started through APB");
        else begin
            $display("ERROR: SPI transaction did not start through APB");
            errors = errors + 1;
        end

        // --------------------------------------------------------
        // WAIT FOR SPI COMPLETE
        // --------------------------------------------------------

        wait(done === 1'b1);

        #2;

        // --------------------------------------------------------
        // CHECK SPI TX
        // --------------------------------------------------------

        if (slave_rx_data === 8'hA5)
            $display("PASS: SPI TX through APB");
        else begin
            $display(
                "ERROR: SPI TX | Expected=A5 | Got=%h",
                slave_rx_data
            );
            errors = errors + 1;
        end

        // --------------------------------------------------------
        // READ SPI RX REGISTER
        // Address = 0x08
        // --------------------------------------------------------

        apb_read(8'h08, read_data);

        if (read_data[7:0] === 8'h65)
            $display("PASS: SPI RX through APB");
        else begin
            $display(
                "ERROR: SPI RX | Expected=65 | Got=%h",
                read_data[7:0]
            );
            errors = errors + 1;
        end

        // --------------------------------------------------------
        // FINAL RESULT
        // --------------------------------------------------------

        if (errors == 0) begin
            $display("--------------------------------");
            $display("APB PERIPHERAL CONTROLLER TEST PASSED");
            $display("--------------------------------");
        end
        else begin
            $display("--------------------------------");
            $display(
                "APB PERIPHERAL CONTROLLER TEST FAILED: %0d errors",
                errors
            );
            $display("--------------------------------");
        end

        #20;
        $finish;

    end

endmodule