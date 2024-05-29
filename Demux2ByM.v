/*
 * DMux
 * ----------------
 * By: Rui van de Ven
 * For: Group 33, ELEC5566M
 * Date: 28/04/2024
 *
 * Description
 * -----------
 * part of the Calculation Pipeline, will be used to enable Paralizing the Calc modules
 * 
 */
 
 module Demux2ByM #(
    //parameters
	 parameter N = 2, //number of outputs
	 parameter M = 32 //Bit Width
)(
    //Declare input and output ports
	 input clk, //clk in to make it synchronous
	 input sel, //select bit
	 input [M-1:0]in,
	 output reg [M-1:0] out0,
	 output reg [M-1:0] out1
);

	always @(posedge clk) begin
		case(sel)
			2'h0: begin
				out0 <= in;
				out1 <= 0;
			end
			2'h1: begin
				out1 <= in;
				out0 <= 0;
			end
			default : $display("Invalid sel input");
		endcase
	end
endmodule