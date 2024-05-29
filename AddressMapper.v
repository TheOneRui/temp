module AddressMapper #(
    parameter FLOAT_PRECISION = 24,
    parameter MAX_X = 64,
    parameter MAX_Y = 48
)(
    input wire clk,
    input wire rst,
    output reg signed [31:0] mapped_x,
    output reg signed [31:0] mapped_y
);


reg [10:0] x, y;

initial begin
    x = 0;
    y = 0;
end

always @(posedge clk) begin
    if (rst) begin
        x <= 0;
        y <= 0;
        mapped_x <= -(2 << FLOAT_PRECISION);
        mapped_y <=  (1 << FLOAT_PRECISION);
    end else begin
        if (x < MAX_X && y < MAX_Y) begin
            // Map [0, MAX_X) to [-2, 1]
            mapped_x <= -(2 << FLOAT_PRECISION) + $signed({{FLOAT_PRECISION{1'b0}}, (x+1)%MAX_X}) * ((1 << FLOAT_PRECISION) * 3) / MAX_X;

            // Map [0, MAX_Y) to [1, -1]
            if (x == MAX_X - 1) begin
                mapped_y <=  (1 << FLOAT_PRECISION) - $signed({{FLOAT_PRECISION{1'b0}}, (y+1)%MAX_Y}) * ((1 << FLOAT_PRECISION) * 2) / MAX_Y;
            end else begin
                mapped_y <=  (1 << FLOAT_PRECISION) - $signed({{FLOAT_PRECISION{1'b0}}, (y+0)%MAX_Y}) * ((1 << FLOAT_PRECISION) * 2) / MAX_Y;
            end
        end
	
        if (x == MAX_X - 1) begin
            if (y != MAX_Y - 1) begin
                x <= 0;
                y <= y + 1;
            end
        end else begin
            x <= x + 1;
        end
    end
end

endmodule
