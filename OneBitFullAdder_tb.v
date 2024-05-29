`timescale 1 ns/100 ps

module OneBitFullAdder_tb;

reg a;
reg b;
reg c_in;

wire sum;
wire c_out;

OneBitFullAdder dut(
	a,
	b,
	c_in,
	sum,
	c_out
);

integer i;

initial begin
	c_in = 1'b0;
	
	for(i=0;i<4;i=i+1) begin
	
	{b,a} = i;
	
	#10;
	
	end
	
	$stop;
	
end

endmodule
