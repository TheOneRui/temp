`timescale 1ns / 1ps

module MandelbrotSet_tb;

    parameter H_ACTIVE = 64;
    parameter V_ACTIVE = 48;
    parameter BIT_WIDTH = 32; // Assuming 32-bit for color values and addresses

    // Inputs
    reg clk;
    reg reset;

    // Outputs
    wire VGA_HS;
    wire VGA_VS;
    wire [7:0] VGA_R;
    wire [7:0] VGA_G;
    wire [7:0] VGA_B;
    wire VGA_SYNC;
    wire VGA_CLK;
    wire VGA_BLANK;

    // Instantiate the Unit Under Test (UUT)
    MandelbrotSet	uut (
        .clk(clk),
        .reset(reset),
        .VGA_HS(VGA_HS),
        .VGA_VS(VGA_VS),
        .VGA_R(VGA_R),
        .VGA_G(VGA_G),
        .VGA_B(VGA_B),
        .VGA_SYNC(VGA_SYNC),
        .VGA_CLK(VGA_CLK),
        .VGA_BLANK(VGA_BLANK)
    );

	 
	initial begin 
		clk = 0;
		forever begin
			#10 clk = ~clk;
		end 
	end

    // Simulation control
    initial begin
        // Initialize inputs
        reset = 1'b1;
        #100; // Assert reset for a short period
        reset = 1'b0;

        // Monitor output for a specific duration to observe behavior
        #60000; // Run the simulation for some time to cover several VGA frames

        // End simulation
        $display("Simulation complete.");
        $finish;
    end

    // Optional: Add additional procedural blocks to monitor changes
    // in VGA signals and other outputs to verify their correctness.
    always @(posedge clk) begin
        if (!reset) begin
            // Log some useful information about VGA signals
            $monitor("Time: %t, HSYNC: %b, VSYNC: %b, R: %h, G: %h, B: %h", 
                     $time, VGA_HS, VGA_VS, VGA_R, VGA_G, VGA_B);
        end
    end

endmodule
