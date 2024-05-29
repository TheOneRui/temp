/* onebitfulladder.v
*--------------------
*By: David Moore
*Date: 4th October 2018
*
*Module Description:
*----------------------
*single bit full adder module
*
*Inputs:
*a - first number to add
*b - second number to add
*c_in - carry in
*
*Outputs:
*sum - the sum of the two input values and carry in
*c_out - carry out
*/

module OneBitFullAdder(
	input a,
	input b,
	input c_in,
	
	output sum,
	output c_out


);

	wire w1;
	wire w2;
	wire w3;
	
	//Sum
	xor(w1,a,b);
	xor(sum,w1,c_in);
	
	//carry
	and(w2,w1,c_in);
	and(w3,a,b);
	or(c_out,w2,w3);
	
endmodule