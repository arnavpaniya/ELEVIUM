`timescale 1ns/1ps

module clock_divider_tb;

    reg clk;
    reg reset;

    wire clk_out;

    integer input_edges;
    integer output_edges;

    clock_divider uut (
        .clk    (clk),
        .reset  (reset),
        .clk_out(clk_out)
    );

    // 10 ns input clock
    always #5 clk = ~clk;

    // Count input clock edges
    always @(posedge clk) begin
        if (!reset)
            input_edges = input_edges + 1;
    end

    // Count output clock edges
    always @(posedge clk_out) begin
        if (!reset)
            output_edges = output_edges + 1;
    end

    initial begin

        $dumpfile("sim/waves/clock_divider.vcd");
        $dumpvars(0, clock_divider_tb);

        clk = 1'b0;
        reset = 1'b1;

        input_edges = 0;
        output_edges = 0;

        // Reset
        #10;

        reset = 1'b0;

        // Run for 100 ns
        #100;

        $display("--------------------------------");
        $display("Clock Divider Simulation Complete");
        $display("Input clock edges : %0d", input_edges);
        $display("Output clock edges: %0d", output_edges);
        $display("--------------------------------");

        $finish;

    end

endmodule