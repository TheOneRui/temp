/*
 * NBitAdderSubtractor
 * ----------------
 * By: Rui van de Ven
 * For: Group 33, ELEC5566M
 * Date: 23/04/2024
 *
 * Description
 * -----------
 * The module is used to do either a subtraction or addition operation on the
 * input variables a and b, with select bit to choose between addition or subtraction
 *	set default number of bits to 27, the length of the multiplier
 * select = 1 is subtraction, select = 0 is addition
 */

module NBitAdderSubtractor #(
    parameter N = 32  //default number of bits = Q5.26
)(
    // Declare input and output ports
    input  [N-1:0] a,
    input  [N-1:0] b,
    input          c_in,
	 input          select, //1 is subtraction, 0 is addition
    output [N-1:0] sum,
    output         c_out
);

reg [N-1:0] TwosComplement;

always @(*) begin
	if (select) begin
		TwosComplement = ~b + 1'b1;
	end else begin
		TwosComplement = b;
	end
end


AdderNBit #(
	 .N  		(				N) //change the number of bits to N
) BigAdder (
	 // Declare input and output ports
	 .a		(					a),
	 .b		( TwosComplement),
	 .c_in	(				c_in),
	 .sum		(				 sum),
	 .c_out	(			  c_out)
);

endmodule
