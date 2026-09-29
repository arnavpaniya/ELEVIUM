`timescale 1ns/1ps

module counter_tb;

    reg clk;
    reg reset;
    reg enable;

    wire [3:0] count;

    integer errors;

    counter #(
        .WIDTH(4)
    ) uut (
        .clk   (clk),
        .reset (reset),
        .enable(enable),
        .count (count)
    );

    always #5 clk = ~clk;

    initial begin

        $dumpfile("sim/waves/counter.vcd");
        $dumpvars(0, counter_tb);

        clk = 1'b0;
        reset = 1'b1;
        enable = 1'b0;
        errors = 0;

        // Reset
        @(posedge clk);
        #1;

        if (count !== 4'd0) begin
            $display("ERROR: Counter did not reset");
            errors = errors + 1;
        end

        reset = 1'b0;

        // Enable counting
        enable = 1'b1;

        repeat (5) begin
            @(posedge clk);
            #1;
        end

        if (count !== 4'd5) begin
            $display("ERROR: Expected count=5, Got=%0d", count);
            errors = errors + 1;
        end
        else begin
            $display("PASS: Counter reached 5");
        end

        // Disable counting
        enable = 1'b0;

        @(posedge clk);
        #1;

        if (count !== 4'd5) begin
            $display("ERROR: Counter changed while disabled");
            errors = errors + 1;
        end
        else begin
            $display("PASS: Counter held value when disabled");
        end

        // Final result
        if (errors == 0) begin
            $display("--------------------------------");
            $display("COUNTER TEST PASSED");
            $display("--------------------------------");
        end
        else begin
            $display("--------------------------------");
            $display("COUNTER TEST FAILED: %0d errors", errors);
            $display("--------------------------------");
        end

        $finish;

    end

endmodule