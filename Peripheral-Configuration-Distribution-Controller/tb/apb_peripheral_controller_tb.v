`timescale 1ns/1ps

module apb_peripheral_controller_tb;

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

    apb_peripheral_controller dut (
        .pclk    (pclk),
        .presetn (presetn),

        .paddr   (paddr),
        .psel    (psel),
        .penable (penable),
        .pwrite  (pwrite),
        .pwdata  (pwdata),

        .prdata  (prdata),
        .pready  (pready),
        .pslverr (pslverr),

        .miso    (miso),

        .mosi    (mosi),
        .sclk    (sclk),
        .cs      (cs),

        .busy    (busy),
        .done    (done)
    );

    always #5 pclk = ~pclk;

    always @(negedge sclk) begin
        if (!cs)
            miso <= slave_tx_data[7-bit_count];
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

    task apb_write_task;
        input [7:0] addr;
        input [31:0] data;

        begin

            @(posedge pclk);
            paddr   <= addr;
            pwdata  <= data;
            pwrite  <= 1'b1;
            psel    <= 1'b1;
            penable <= 1'b0;

            @(posedge pclk);
            penable <= 1'b1;

            @(posedge pclk);
            psel    <= 1'b0;
            penable <= 1'b0;
            pwrite  <= 1'b0;

        end
    endtask

    task apb_read_task;
        input [7:0] addr;

        begin

            @(posedge pclk);
            paddr   <= addr;
            pwrite  <= 1'b0;
            psel    <= 1'b1;
            penable <= 1'b0;

            @(posedge pclk);
            penable <= 1'b1;

            @(posedge pclk);
            psel    <= 1'b0;
            penable <= 1'b0;

        end
    endtask

    initial begin

        $dumpfile("sim/waves/apb_peripheral_controller.vcd");
        $dumpvars(0, apb_peripheral_controller_tb);

        pclk    = 1'b0;
        presetn = 1'b0;

        paddr   = 8'b0;
        psel    = 1'b0;
        penable = 1'b0;
        pwrite  = 1'b0;
        pwdata  = 32'b0;

        miso = 1'b0;

        slave_tx_data = 8'b01100101;
        slave_rx_data = 8'b0;

        bit_count = 0;
        errors = 0;

        #20;
        presetn = 1'b1;

        if (pready !== 1'b1) begin
            $display("ERROR: PREADY");
            errors = errors + 1;
        end
        else
            $display("PASS: PREADY");

        if (pslverr !== 1'b0) begin
            $display("ERROR: PSLVERR");
            errors = errors + 1;
        end
        else
            $display("PASS: PSLVERR");

        // Write TX data
        apb_write_task(8'h00, 32'h000000A5);

        // Read TX data
        apb_read_task(8'h00);
        #1;

        if (prdata !== 32'h000000A5) begin
            $display("ERROR: TX register readback");
            errors = errors + 1;
        end
        else
            $display("PASS: TX register readback");

        // Start SPI
        apb_write_task(8'h04, 32'h00000001);

        // Wait for controller to become busy
        wait(busy == 1'b1);

        $display("PASS: SPI transaction started through APB");

        // Wait for transaction completion
        wait(done == 1'b1);

        #10;

        if (slave_rx_data !== 8'hA5) begin
            $display(
                "ERROR: SPI TX | Expected=%h | Got=%h",
                8'hA5,
                slave_rx_data
            );
            errors = errors + 1;
        end
        else
            $display("PASS: SPI TX through APB");

        // Read RX register
        apb_read_task(8'h08);
        #1;

        if (prdata[7:0] !== slave_tx_data) begin
            $display(
                "ERROR: SPI RX | Expected=%h | Got=%h",
                slave_tx_data,
                prdata[7:0]
            );
            errors = errors + 1;
        end
        else
            $display("PASS: SPI RX through APB");

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

        $finish;

    end

endmodule