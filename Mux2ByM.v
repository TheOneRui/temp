/*
 * Mux
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
 
 module Mux2ByM #(
    //parameters
	 parameter N = 2, //number of outputs
	 parameter M = 32 //Bit Width
)(
    //Declare input and output ports
	 input clk, //clk in to make it synchronous
	 input sel, //select bit
	 input [M-1:0]in0,
	 input [M-1:0]in1,
	 output reg [M-1:0] out
);

	always @(posedge clk) begin
		case(sel)
			2'h0:	out <= in0;
			2'h1:	out <= in1;
			default : $display("Invalid sel input");
		endcase
	end
endmodule