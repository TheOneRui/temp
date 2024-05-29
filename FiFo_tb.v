/*
 * FiFo
 * ----------------
 * Credits: VLSIverify
 * Modified: Rui van de Ven
 * For: Group 33, ELEC5566M
 * Date: 30/04/2024
 *
 * Description
 * -----------
 * Test bench for the FiFo module
 * Test Bench based on the Test Bench written by VLSIverify.com
 * modified to be applicable to our FiFO
 * Chipverify.com was also used as a reference for Verilog functionality
 * 
 */
 
`timescale 1ns/1ps

module FiFo_tb;
	parameter BIT_WIDTH = 8;
	  
	reg clk, rst;
	reg w_cntrl;
	reg r_cntrl;
	reg [BIT_WIDTH-1:0] data_in;
	wire [BIT_WIDTH-1:0] data_out;
	wire full;
	wire empty;

	// Queue to push data_in
	reg [BIT_WIDTH-1:0] storage[320:0];
	reg [BIT_WIDTH-1:0] compare_var;

	FiFo #(.BIT_WIDTH (BIT_WIDTH))DUT(
		.clk (clk), 
		.rst (rst), 
		.w_cntrl (w_cntrl),
		.r_cntrl (r_cntrl), 
		.data_in (data_in), 
		.data_out (data_out), 
		.full (full), 
		.empty (empty)
	);

	initial begin 
		clk = 0;
		forever begin
			#20 clk = ~clk;
		end 
	end
	
	// RUN TIME VARIABLES
	integer	i, j, k, l;
	integer count_w;
	integer count_r;

	initial begin
		clk <= 1'b0; 
		rst <= 1'b1;
		w_cntrl <= 1'b0;
		data_in <= 0;
		count_w <= 0;
		 
		for (i=0; i<10; i = i + 1) begin //wait 10 clock cycles
			@(posedge clk); 
		end
		rst <= 1'b0;

		for (j=0; j<30; j = j + 1) begin //load the FiFO with random data
			@(posedge clk);
			w_cntrl = (j%2 == 0)? 1'b1 : 1'b0;
			if (w_cntrl & !full) begin
				data_in <= $urandom;
				storage[count_w] <= data_in;
				count_w <= count_w + 1;
			end
		end
	end

	initial begin
		clk <= 1'b0; 
		rst <= 1'b1;
		r_cntrl <= 1'b0;
		count_r <= 0;

		for (k=0; k<20; k = k + 1) begin //wait 20 clock cycles
			@(posedge clk); 
		end
		rst <= 1'b0;

		for (l =0; l<30; l = l + 1) begin
			@(posedge clk);
			r_cntrl = (l%2 == 0)? 1'b1 : 1'b0;
			if (r_cntrl & !empty) begin
				compare_var <= storage[count_r];
				if(data_out !== compare_var) $error("Comparison Failed: expected wr_data = %h, rd_data = %h", compare_var, data_out);
				else $display("Comparison Passed: wr_data = %h and rd_data = %h", compare_var, data_out);
				count_r <= count_r + 1;
			end
		end
		$finish;
	end
endmodule
