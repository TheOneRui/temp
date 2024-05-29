`timescale 1ns/1ps

module AddressMapper_tb;

    parameter FLOAT_PRECISION = 24;
    parameter MAX_X = 64;
    parameter MAX_Y = 48;
    reg clk;
    reg rst;
    wire signed [31:0] mapped_x;
    wire signed [31:0] mapped_y;

    AddressMapper #(
        .FLOAT_PRECISION(FLOAT_PRECISION),
        .MAX_X(MAX_X),
        .MAX_Y(MAX_Y)
    ) dut (
        .clk(clk),
        .rst(rst),
        .mapped_x(mapped_x),
        .mapped_y(mapped_y)
    );

    // Clock generation
    initial begin
        clk = 0;
        forever #5 clk = ~clk; // Toggle clock every 5 time units
    end

    // Reset and run
    initial begin
        rst = 1; // set reset
        #10; // Wait for 10 time units
        rst = 0; // de-set reset
    end

    // Display mapped values
    always @(posedge clk) begin
        if (!rst) begin
            $display("Mapped values: (%f, %f)", $itor(mapped_x * 2.0**-FLOAT_PRECISION), $itor(mapped_y * 2.0**-FLOAT_PRECISION));
        end
    end

endmodule
