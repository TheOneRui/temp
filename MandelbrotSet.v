module ClockDivider(
    input clk_in,  // Input clock at 50 MHz
    output reg clk_out  // Output clock at 25 MHz
);

    // Initialize the output clock to low
    initial clk_out = 0;

    always @(posedge clk_in) begin
        clk_out <= ~clk_out;  // Toggle the output clock on each rising edge of the input clock
    end

endmodule

module MandelbrotSet(
    input wire clk,     // 25 MHz
    input wire reset,	// Active high

    output wire VGA_HS,	// HSYNC (to VGA connector)
    output wire VGA_VS,	// VSYNC (to VGA connctor)
    output [7:0] VGA_R,	// RED (to resistor DAC VGA connector)
    output [7:0] VGA_G,	// GREEN (to resistor DAC to VGA connector)
    output [7:0] VGA_B,	// BLUE (to resistor DAC to VGA connector)
    output VGA_SYNC,		// SYNC to VGA connector
    output VGA_CLK,		// CLK to VGA connector
    output VGA_BLANK		// BLANK to VGA connector
);

	 parameter H_ACTIVE	= 64;// Active video horizontal length
	 parameter V_ACTIVE	= 48;// Active video vertical height

	 wire	clk_25Mhz;
	 ClockDivider	div(
		.clk_in(clk),
		.clk_out(clk_25Mhz)
	 );
		
	wire [31:0] real_part, imaginary_part;

	wire cntrl_address;
	wire r_cntrl_fifo, empty_wire;
	wire full_real_wire, full_imag_wire;

	wire [31:0] color_val;
	reg [$clog2(H_ACTIVE)-1:0] counter_H;
	reg [$clog2(V_ACTIVE)-1:0] counter_V;

	// Declaration of the 2D register array
	reg	[8:0] display_buffer[H_ACTIVE-1:0][V_ACTIVE-1:0];
	reg	[8:0]	display_pointer;
	 

	assign cntrl_address = clk_25Mhz && (!full_real_wire && !full_imag_wire); 
//	//	AddressMapper



	AddressMapper	#(
		.MAX_X 		(H_ACTIVE),
		.MAX_Y 		(V_ACTIVE)
	)	addmap(
		.clk			(cntrl_address),
		.rst			(reset),
		.mapped_x	(real_part),
		.mapped_y	(imaginary_part)
	);
	
//	//	PIPE
	Pipe	pipe(
		.clk(clk_25Mhz),
		.rst(reset),
		.w_cntrl_real(!full_real_wire),
		.w_cntrl_imag(!full_imag_wire),
		.r_cntrl(r_cntrl_fifo),
		.data_in_real(real_part),
		.data_in_imag(imaginary_part),
		
		.data_out(color_val),
		.full_real(full_real_wire), 
		.full_imag(full_imag_wire), 
		.empty(empty_wire) 
	);
	
	assign r_cntrl_fifo = !empty_wire;
	
	 // Instantiate VGADriver                   
	 VGADriver	driver( 
		.clk(clk_25Mhz),	// 25 MHz PLL
		.reset(reset),
		
		.red_in(display_pointer[8:6]	<< 2 | 2'b11),
		.green_in(display_pointer[5:3]<< 2 | 2'b11),
		.blue_in(display_pointer[2:0]	<< 2 | 2'b11),
		
		.vga_sync(VGA_SYNC),
		.vga_clk(VGA_CLK),
		.vga_blank(VGA_BLANK),
		.hsync(VGA_HS),
		.vsync(VGA_VS),
		
		.vga_red(VGA_R),
		.vga_green(VGA_G),
		.vga_blue(VGA_B)
	 );

	integer i, j;
	always @(posedge clk) begin
		if (reset) begin
			for (i = 0; i < H_ACTIVE; i = i + 1) begin
				for (j = 0; j < V_ACTIVE; j = j + 1) begin
					display_buffer[i][j]	<= 9'd0;
					$display("CHECK THIS RESET HOMIE (display_pointer) = %d", display_pointer);
				end
			end
			counter_H <= 0;
			counter_V <= 0;
		end
		
		else	begin
			for (i = 0; i < H_ACTIVE; i = i + 1) begin
				for (j = 0; j < V_ACTIVE; j = j + 1) begin
					display_pointer	<=	display_buffer[i][j];
					$display("CHECK THIS HOMIE (display_pointer) = %d", display_pointer);
				end
			end
		end
		
		if(r_cntrl_fifo) begin
			display_buffer[counter_H][counter_V]	=	color_val;
			$display("CHECK THIS HOMIE (color_val) = %d", color_val);
			
			if	(color_val)	begin
				$finish;
			end
			
			if(counter_H < H_ACTIVE) begin
				counter_H <=	counter_H + 1;
			end else begin
				counter_H <=	counter_H + 1;
				counter_V <=	counter_V + 1;
			end
		end
	end

endmodule
