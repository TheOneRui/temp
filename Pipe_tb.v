/*
 * Pipe tb
 * ----------------
 * Credits: VLSIverify
 * Modified: Rui van de Ven
 * For: Group 33, ELEC5566M
 * Date: 30/04/2024
 *
 * Description
 * -----------
 * Test bench for the Pipe module
 * 
 */

`timescale 1ns / 1ps

module Pipe_tb;

    parameter BIT_WIDTH = 32;

    // Inputs
    reg clk;
    reg rst;
    reg w_cntrl_real;
    reg w_cntrl_imag;
    reg r_cntrl;
    reg [BIT_WIDTH-1:0] data_in_real;
    reg [BIT_WIDTH-1:0] data_in_imag;

    // Outputs
    wire [BIT_WIDTH-1:0] data_out;
    wire full_real;
    wire full_imag;
    wire empty;
	 
	 
	 //wires
	 wire [BIT_WIDTH-1:0]real_part, imaginary_part;
	 
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
    Pipe #(
        .N(16),
        .BIT_WIDTH(BIT_WIDTH),
        .MAX_ITERATIONS(512),
        .FLOAT_PRECISION(26)
    ) Dut (
        .clk(clk),
        .rst(rst),
        .w_cntrl_real(w_cntrl_real),
        .w_cntrl_imag(w_cntrl_imag),
        .r_cntrl(r_cntrl),
        .data_in_real(data_in_real),
        .data_in_imag(data_in_imag),
        .data_out(data_out),
        .full_real(full_real),
        .full_imag(full_imag),
        .empty(empty)
    );

    // Clock generation
    always #20 clk = ~clk;

    // Test stimuli
    integer i;
	 
    initial begin
        // Initialize Inputs
        clk <= 0;
        rst <= 1;
        w_cntrl_real <= 0;
        w_cntrl_imag <= 0;
        r_cntrl <= 0;
        data_in_real <= 0;
        data_in_imag <= 0;

        // Reset condition
        #160;
        rst <= 0;
			$stop;

        // Randomized input with write control
        for (i = 0; i < 16; i = i + 1) begin
				@(posedge clk);
				if (!full_real & !full_imag) begin
					w_cntrl_real <= i % 2;
					w_cntrl_imag <= i % 2;
					data_in_real <= real_part;
					data_in_imag <= imaginary_part;
				end
        end
		  w_cntrl_real <= 0;
        w_cntrl_imag <= 0;
		  data_in_real <= 0;
        data_in_imag <= 0;
		  r_cntrl <= 0;
//		  #170000
//		  
//		  // Verify the outputs based on some expected conditions
//		  for (i = 0; i < 16; i = i + 1) begin
//				@(posedge clk);
//				$display("Test result at time %d: got %d", $time, data_out);
//			end
//
//        // Complete simulation
//        $display("Test completed successfully.");
        $stop;
    end

endmodule
