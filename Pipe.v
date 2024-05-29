/*
 * Pipeline (Calc plus required FiFo's)
 * ----------------
 * By: Rui van de Ven
 * For: Group 33, ELEC5566M
 * Date: 30/04/2024
 *
 * Description
 * -----------
 * This module is the combination of the Calculator modules
 * and the required FiFo's to enable synchronous operation
 * there are 2 FiFo's handling providing input values
 * 1 FiFo handles the output of the Calc Module
 * may need to be expanded to have an extra FiFo, which stores the address values
 * an Idea for adding parallelisation.
 * 
 */
 `timescale 1ns / 1ps
 
  module Pipe #(
    //parameters
	 parameter N = 16,
	 parameter BIT_WIDTH = 32,
	 parameter MAX_ITERATIONS = 512,
	 parameter FLOAT_PRECISION = 24
)(
    //Declare input and output ports
	 input clk,
	 input rst,
	 input w_cntrl_real, //real write cntrl
	 input w_cntrl_imag, //imaginary write cntrl
	 input r_cntrl, //result read control
	 input [BIT_WIDTH-1:0] data_in_real, //real input
	 input [BIT_WIDTH-1:0] data_in_imag, //imaginary input
	 output [BIT_WIDTH-1:0] data_out, //result output
	 output full_real, //real fifo full flag
	 output full_imag, //imaginary fifo full flag
	 output empty //result fifo empty flag
);

	//create control wires
	reg r_cntrl_fifo, start; //combinational logic to control read
	//wire w_ctrl_result_fifo; //combinational logic to control write
	
	//create interconnect regs and wires
	wire [BIT_WIDTH-1:0] data_out_real, data_out_imag, calc_results;
	wire empty_real_wire, empty_imag_wire, full_results, result_ready, calc_ready;

	FiFo FiFo_real(
		.clk 					(clk), 
		.rst 					(rst), 
		.w_cntrl				(w_cntrl_real),
		.r_cntrl 			(r_cntrl_fifo), 
		.data_in 			(data_in_real), 
		.data_out 			(data_out_real), 
		.full 				(full_real), 
		.empty 				(empty_real_wire)
	);
	
	FiFo FiFo_imag(
		.clk					(clk), 
		.rst 					(rst), 
		.w_cntrl 			(w_cntrl_imag),
		.r_cntrl 			(r_cntrl_fifo), 
		.data_in 			(data_in_imag), 
		.data_out 			(data_out_imag), 
		.full 				(full_imag), 
		.empty 				(empty_imag_wire)
	);
	
	
	MandelbrotCalculator #(
		.BIT_WIDTH 							(BIT_WIDTH),
		.MAX_ITERATIONS 					(MAX_ITERATIONS),
		.FLOAT_PRECISION 					(FLOAT_PRECISION)
	) calc (
		.clk 									(clk), 
		.rst 									(rst), 
		.real_part 							(data_out_real),
		.imaginary_part 					(data_out_imag),
		.start								(r_cntrl_fifo),
		.out_ready 							(result_ready),
		.colour_data 						(data_out),
		.ready_for_input 					(calc_ready)
	);
	
	
//	FiFo FiFo_result(
//		.clk 					(clk), 
//		.rst 					(rst), 
//		.w_cntrl 			(w_ctrl_result_fifo),
//		.r_cntrl 			(r_cntrl), 
//		.data_in 			(calc_results), 
//		.data_out 			(data_out), 
//		.full 				(full_results), 
//		.empty 				(empty)
//	);
	
	always @(posedge clk) begin 
		r_cntrl_fifo <= !empty_real_wire & !empty_imag_wire & calc_ready; //combinational logic to control read
		start <= #5 r_cntrl_fifo;
	end
	//assign w_ctrl_result_fifo = !full_results & result_ready; //combinational logic to control write
	assign empty = !result_ready;
	
	always @(posedge clk) begin
		$display("\nCHECK THIS FiFo_imag w_cntrl_imag = %d", w_cntrl_imag);
		$display("\nCHECK THIS FiFo_real w_cntrl_real = %d", w_cntrl_real);
		$display("\nCHECK THIS FiFo_imag data_in_imag = %f", data_in_imag);
		$display("\nCHECK THIS FiFo_real data_in_real = %f", data_in_real);
		$display("\nCHECK THIS FiFo_imag calc_ready = %d", calc_ready);
		$display("\nCHECK THIS FiFo_imag r_cntrl_imag = %d", r_cntrl_fifo);
		$display("\nCHECK THIS FiFo_real r_cntrl_real = %d", r_cntrl_fifo);
		$display("\nCHECK THIS FiFo_imag data_out_imag = %f", data_out_imag);
		$display("\nCHECK THIS FiFo_real data_out_real = %f", data_out_real);
		$display("\n===============================================");
		$display("\nCHECK THIS calc data_out = %d", data_out);
		$display("\nCHECK THIS calc result_ready = %d", result_ready);
		$display("\n*************************************************");
	end
	
endmodule