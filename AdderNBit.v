/*
* N-Bit Full Adder Example
*/
module AdderNBit #(
    parameter N = 4  //Number of bits in adder (default 4)
)(
    // Declare input and output ports
    input  [N-1:0] a,
    input  [N-1:0] b,
    input          c_in,
    output [N-1:0] sum,
    output         c_out
);

wire [N-0:0] carry;     //Internal carry signal, N+1 wide to include carry in/out
assign carry[0] = c_in;  //First bit is Carry In
assign c_out = carry[N]; //Last bit is Carry Out

genvar i;  //Generate variable to be used in the for loop

generate
    for (i = 0; i < N; i = i + 1) begin : adder_loop //Loop "N" Times.
        localparam j = i + 1;

        //Instantiate "N" 1-bit FullAdder modules
        OneBitFullAdder adder (
            .a   (    a[i]),
            .b   (    b[i]),
            .c_in (carry[i]),
            .sum (  sum[i]),
            .c_out(carry[j])
        );
    end
endgenerate
endmodule