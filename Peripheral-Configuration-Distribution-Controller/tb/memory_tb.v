`timescale 1ns/1ps

module memory_tb;

    reg clk;
    reg reset;

    reg write_en;
    reg [3:0] address;
    reg [7:0] write_data;

    wire [7:0] read_data;

    integer errors;

    memory #(
        .DATA_WIDTH(8),
        .ADDR_WIDTH(4)
    ) uut (
        .clk      (clk),
        .reset    (reset),
        .write_en (write_en),
        .address  (address),
        .write_data(write_data),
        .read_data(read_data)
    );

    always #5 clk = ~clk;

    initial begin

        $dumpfile("sim/waves/memory.vcd");
        $dumpvars(0, memory_tb);

        clk = 1'b0;
        reset = 1'b1;

        write_en = 1'b0;
        address = 4'b0;
        write_data = 8'b0;

        errors = 0;

        // Reset
        @(posedge clk);
        #1;

        reset = 1'b0;

        // ------------------------------------------------
        // Write 0xA5 to address 3
        // ------------------------------------------------

        address = 4'd3;
        write_data = 8'hA5;
        write_en = 1'b1;

        @(posedge clk);
        #1;

        write_en = 1'b0;

        // ------------------------------------------------
        // Read address 3
        // ------------------------------------------------

        @(posedge clk);
        #1;

        if (read_data !== 8'hA5) begin
            $display(
                "ERROR: Expected=0xA5 | Got=0x%h",
                read_data
            );
            errors = errors + 1;
        end
        else begin
            $display("PASS: Correct data read from address 3");
        end

        // ------------------------------------------------
        // Write another value
        // ------------------------------------------------

        address = 4'd7;
        write_data = 8'h5A;
        write_en = 1'b1;

        @(posedge clk);
        #1;

        write_en = 1'b0;

        // Read address 7
        @(posedge clk);
        #1;

        if (read_data !== 8'h5A) begin
            $display(
                "ERROR: Expected=0x5A | Got=0x%h",
                read_data
            );
            errors = errors + 1;
        end
        else begin
            $display("PASS: Correct data read from address 7");
        end

        // ------------------------------------------------
        // Final result
        // ------------------------------------------------

        if (errors == 0) begin
            $display("--------------------------------");
            $display("MEMORY TEST PASSED");
            $display("--------------------------------");
        end
        else begin
            $display("--------------------------------");
            $display("MEMORY TEST FAILED: %0d errors", errors);
            $display("--------------------------------");
        end

        $finish;

    end

endmodule