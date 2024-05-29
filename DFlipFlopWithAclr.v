/*
 * D-Type Flip Flop w/ AClr
 * ========================
 *
 * A simple D-Type Flip Flop Example with
 * asynchronous clear/reset input.
 *
 */

module DFlipFlopWithAclr (
    input clock,
    input reset,
    input d, 
    output reg q
);
always @( posedge clock or posedge reset) begin //At to rising edge of clock or reset 
    if (reset) begin //If the reset signal is high
        q <= 1'b0; //Clear the output q
    end else begin
        q <= d;    //Otherwise load the input value d onto the output q.
    end
end
endmodule
