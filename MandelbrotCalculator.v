module MandelbrotCalculator #(
    parameter BIT_WIDTH = 32,
    parameter MAX_ITERATIONS = 512,
    parameter FLOAT_PRECISION = 24
)(
    input clk,
    input rst,
    input[BIT_WIDTH-1:0] real_part,
    input[BIT_WIDTH-1:0] imaginary_part,
    input start, // Added start signal to initiate computation
    output reg out_ready,
    output reg [BIT_WIDTH-1:0] colour_data,
    output reg ready_for_input
);

//AddressMapper address_map ();

reg[BIT_WIDTH-1:0] a, b;
reg[BIT_WIDTH-1:0]a_next, b_next;
reg[BIT_WIDTH-1:0]counter;

reg[BIT_WIDTH-1:0] a_sqr, b_sqr, ab_times_two, a_sqr_plus_b_sqr;

reg[31:0] escape_val;

    always @(posedge clk) begin
        if (rst) begin
            a <= 0;
            b <= 0;
            counter <= 0;
            out_ready <= 0;
            ready_for_input <= 1;
				colour_data <= counter;
        end else if (start && ready_for_input) begin
            a <= real_part;
            b <= imaginary_part;
            ready_for_input <= 0;
				counter <= 0;
				out_ready <= 0;
        end else if (!ready_for_input) begin
            // Perform the iteration calculation
				process_a_b();

            a = a_next;
            b = b_next;

            if ((a_sqr_plus_b_sqr > escape_val) || (counter >= MAX_ITERATIONS)) begin
                out_ready = 1;
                ready_for_input = 1;
                colour_data = (counter % MAX_ITERATIONS); // Direct iteration count; adjust for color as needed
            end else begin
                counter = counter + 1;
            end
        end
    end

task process_a_b;
begin
a_sqr=qmult(a, a);
b_sqr =qmult(b, b);
ab_times_two = qmult(a, b) << 1; // Corrected to use shift for multiplying by 2

$display("\nCHECK THIS (a, b) = %f, %f", a, b);
//$display("CHECK THIS (a_sqr, b_sqr, ab_times_two) = %f, %f, %f", a_sqr, b_sqr, ab_times_two);

a_next= qadd(a_sqr - b_sqr, real_part);
b_next= qadd(ab_times_two, imaginary_part);

a_sqr_plus_b_sqr = a_sqr + b_sqr;

//$display("CHECK THIS (a_next, b_next, a_sqr_plus_b_sqr) = %f, %f, %f\n", a_next, b_next, a_sqr_plus_b_sqr);

escape_val = ((1 << FLOAT_PRECISION) * 4); // Corrected escape condition scaling
end
endtask
 

    // Fixed-point adder
function [BIT_WIDTH-1:0] qadd(input signed [BIT_WIDTH-1:0] x, input signed [BIT_WIDTH-1:0] y);
begin
qadd = x + y;
end
endfunction

// Fixed-point multiplier
function [BIT_WIDTH-1:0] qmult(input signed [BIT_WIDTH-1:0] x, input signed [BIT_WIDTH-1:0] y);
reg signed [2*BIT_WIDTH-1:0] temp_product;
begin
temp_product = x * y;
qmult = temp_product >>> FLOAT_PRECISION;// Adjust shifting to correctly scale back the result
end
endfunction

endmodule