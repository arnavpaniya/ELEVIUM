`timescale 1ns/1ps

module cdc_tb;

    reg clk;
    reg reset;
    reg async_in;

    wire sync_out;

    integer errors;

    cdc uut (
        .clk     (clk),
        .reset   (reset),
        .async_in(async_in),
        .sync_out(sync_out)
    );

    always #5 clk = ~clk;

    initial begin

        $dumpfile("sim/waves/cdc.vcd");
        $dumpvars(0, cdc_tb);

        clk = 1'b0;
        reset = 1'b1;
        async_in = 1'b0;
        errors = 0;

        // Reset
        @(posedge clk);
        #1;

        if (sync_out !== 1'b0) begin
            $display("ERROR: CDC output not reset");
            errors = errors + 1;
        end

        reset = 1'b0;

        // Drive input high
        async_in = 1'b1;

        // Two synchronizer stages
        @(posedge clk);
        #1;

        if (sync_out !== 1'b0) begin
            $display("ERROR: CDC synchronized too early");
            errors = errors + 1;
        end

        @(posedge clk);
        #1;

        if (sync_out !== 1'b1) begin
            $display("ERROR: CDC failed to synchronize HIGH");
            errors = errors + 1;
        end
        else begin
            $display("PASS: CDC synchronized HIGH");
        end

        // Drive input low
        async_in = 1'b0;

        @(posedge clk);
        #1;

        if (sync_out !== 1'b1) begin
            $display("ERROR: CDC changed too early");
            errors = errors + 1;
        end

        @(posedge clk);
        #1;

        if (sync_out !== 1'b0) begin
            $display("ERROR: CDC failed to synchronize LOW");
            errors = errors + 1;
        end
        else begin
            $display("PASS: CDC synchronized LOW");
        end

        // Final result
        if (errors == 0) begin
            $display("--------------------------------");
            $display("CDC TEST PASSED");
            $display("--------------------------------");
        end
        else begin
            $display("--------------------------------");
            $display("CDC TEST FAILED: %0d errors", errors);
            $display("--------------------------------");
        end

        $finish;

    end

endmodule