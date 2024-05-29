/*
 * Clock Divider
 * ----------------
 * By: Rui van de Ven
 * For: Group 33, ELEC5566M
 * Date: 23/04/2024
 *
 * Description
 * -----------
 * This module divides a clock by 2 N times
 */

module NClockDivider #(
    parameter N = 1  //default divider to divide once
)(
    // Declare input and output ports
    input  			clk_in, //clock in
	 input			reset, //reset clock
    output 			clk_out //clock out
);

wire [N-0:0] clk_interconnect;
assign clk_interconnect[0] = clk_in;
assign clk_out = clk_interconnect[N];

genvar i;  //Generate variable to be used in the for loop

generate
    for (i = 0; i < N; i = i + 1) begin : divider_loop //Loop "N" Times.
        localparam j = i + 1;

        //Instantiate "N" D type Flip Flops
        DFlipFlopWithAclr DFlipFlop (
            .clock   (    clk_interconnect[i]),
            .reset   (    				reset),
            .d 		(	  ~clk_interconnect[j]),
				.q			(	  clk_interconnect[j])
        );
    end
endgenerate
endmodule