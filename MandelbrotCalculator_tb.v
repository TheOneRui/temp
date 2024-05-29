`timescale 1ns / 1ps

module MandelbrotCalculator_tb;

    parameter BIT_WIDTH = 32;

// Inputs
reg clk, rst, start;
wire signed [BIT_WIDTH-1:0] real_part;
wire signed [BIT_WIDTH-1:0] imaginary_part;
// Outputs
wire out_ready;
wire [BIT_WIDTH-1:0] colour_data;
wire ready_for_input;
 
 
AddressMapper #(
.FLOAT_PRECISION(24),
.MAX_X(64),
.MAX_Y(48)
) address_map (
.clk(clk),
.rst(rst),
.mapped_x(real_part),
.mapped_y(imaginary_part)
);

// Instantiate the Unit Under Test (UUT)
MandelbrotCalculator #(
.BIT_WIDTH(BIT_WIDTH),
.MAX_ITERATIONS(512),
.FLOAT_PRECISION(24)
) uut (
.clk(clk),
.rst(rst),
.real_part(real_part),
.imaginary_part(imaginary_part),
.start(start),
.out_ready(out_ready),
.colour_data(colour_data),
.ready_for_input(ready_for_input)
);

    // Clock generation
initial begin 
clk = 0;
forever begin
#20 clk = ~clk;
end 
end


// Initialize Inputs
initial begin
// Initialize Inputs
rst = 1;
#40;
// Wait 100 ns for global reset to finish
rst = 0;
start=1;
// Additional test cases can be added here

// Finish simulation
#10000;
$finish;
end

endmodule