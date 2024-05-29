`timescale 1ns/1ps

`define assert(signal, value, sig_1, sig_2) \
        if (signal != value) begin \
            $display("ASSERTION FAILED in %m: %s != %s", sig_1, sig_2); \
				$finish; \
        end
	

module VGADriver_tb;

    reg clk;  // 25 MHz clock
    reg reset;

    reg [7:0] red_in;
    reg [7:0] green_in;
    reg [7:0] blue_in;

    wire [9:0] x;
    wire [9:0] y;

    wire vga_sync;
    wire vga_clk;
    wire vga_blank;
    wire hsync;
    wire vsync;

    wire [7:0] vga_red;
    wire [7:0] vga_green;
    wire [7:0] vga_blue;

    // Instantiate the VGA Driver module
    VGADriver dut (
        .clk(clk),
        .reset(reset),
        .red_in(red_in),
        .green_in(green_in),
        .blue_in(blue_in),
        .x(x),
        .y(y),
        .vga_sync(vga_sync),
        .vga_clk(vga_clk),
        .vga_blank(vga_blank),
        .hsync(hsync),
        .vsync(vsync),
        .vga_red(vga_red),
        .vga_green(vga_green),
        .vga_blue(vga_blue)
    );

	 // RUN TIME VARIABLES
	integer	i;
	
	initial begin 
		clk = 0;
		forever begin
			#20 clk = ~clk;
		end 
	end

	// Test sequence
	initial begin
		// Initialize inputs

		// Apply reset
		reset		=	1;		
		red_in	= 8'd0;
		green_in	= 8'd0;
		blue_in	= 8'd0;
		#40;
		reset = 0;
		// #20;
		
		// Test different colors
		red_in = 8'hFF; green_in = 8'h00; blue_in = 8'h00;  // Red
		#40;
		for (i = 0; i < 255;	i = i + 1)	begin
			red_in	=	red_in - 1;
			green_in	=	green_in + 1;
			blue_in	=	8'h00;
			#40;

		end
		
		$display("%d ns\tSimulation Finished",$time); //Finished
		$stop();
	


	end

    // Monitor and check outputs
    always @(negedge clk) begin
        if (!reset) begin
            // Check for clock consistency
            `assert(vga_clk, clk, "vga_clk", "clk")

            // Verify vga_sync, vga_blank, hsync, and vsync
            `assert(vga_sync, 1'b0, "vga_sync", "1'b0")
            `assert(vga_blank, (hsync && vsync), "vga_blank", "(hsync && vsync)")

            // Check output colors
            if (x < 640 && y < 480) begin
                `assert(vga_red, red_in, "vga_red", "red_in")
                `assert(vga_green, green_in, "vga_green", "green_in")
                `assert(vga_blue, blue_in, "vga_blue", "blue_in")
            end else begin
                `assert(vga_red, 0, "vga_red", "0")
                `assert(vga_green, 0, "vga_green", "0")
                `assert(vga_blue, 0, "vga_blue", "0")
            end

        end else begin
            // Ensure outputs are reset properly
            `assert(vga_red, 0, "vga_red", "0")
            `assert(vga_green, 0, "vga_green", "0")
            `assert(vga_blue, 0, "vga_blue", "0")
            `assert(hsync, 0, "hsync", "0")
            `assert(vsync, 0, "vsync", "0")
        end
    end

endmodule
