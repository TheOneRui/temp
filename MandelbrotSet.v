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
    input wire clk,     // 50 MHz
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

	parameter H_ACTIVE	= 32;// Active video horizontal length
	parameter V_ACTIVE	= 24;// Active video vertical height
	 
	reg [$clog2(H_ACTIVE)-1:0] counter_H;
	reg [$clog2(V_ACTIVE)-1:0] counter_V;

	// Declaration of the 2D register array
	reg	[8:0] display_buffer[H_ACTIVE-1:0][V_ACTIVE-1:0];
	reg	[8:0]	display_pointer;
	 

	wire	clk_25Mhz;
	ClockDivider	div(
		.clk_in			(clk),
		.clk_out			(clk_25Mhz)
	);
	
	reg complete;
	
	
	//Calculator Wires/Connectivity
	//==========================================
	//control wires
	wire calc_rdy, calc_start, calc_out_rdy, calc_clk;
	assign calc_clk = (clk_25Mhz & !complete); //may need to add cntrl/timing logic here
	
	//output wires
	wire [31:0] calc_result;
	
	
	//==========================================
	//Calculator Wires/Connectivity
	
	//address mapper Wires/Connectivity
	//==========================================
	//output wires
	wire [31:0] real_part, imaginary_part;

	//control wire for address mapper
	wire address_clk;
	assign address_clk = (clk_25Mhz & calc_rdy & !complete);
	//==========================================
	//address mapper Wires/Connectivity
	 
	 
	 
	 

//	//	AddressMapper
	AddressMapper	#(
		.MAX_X 		(H_ACTIVE),
		.MAX_Y 		(V_ACTIVE)
	)	addmap(
		.clk			(address_clk),
		.rst			(reset),
		.mapped_x	(real_part),
		.mapped_y	(imaginary_part)
	);
	
	
	
	
//	//	Calc
	MandelbrotCalculator calc(
		 .clk						(calc_clk),
		 .rst						(reset),
		 .real_part				(real_part),
		 .imaginary_part		(imaginary_part),
		 .start					(calc_start), 
		 .out_ready				(calc_out_rdy),
		 .colour_data			(calc_result),
		 .ready_for_input		(calc_rdy)
	);
	
	
	
	
	

	
	 // Instantiate VGADriver                   
	 VGADriver	driver( 
		.clk								(clk_25Mhz),	// 25 MHz PLL
		.reset							(reset),
		
		.red_in							({display_pointer[8:6], 2'b11}),
		.green_in						({display_pointer[5:3], 2'b11}),
		.blue_in							({display_pointer[2:0], 2'b11}),
		
		.vga_sync						(VGA_SYNC),
		.vga_clk							(VGA_CLK),
		.vga_blank						(VGA_BLANK),
		.hsync							(VGA_HS),
		.vsync							(VGA_VS),
		
		.vga_red							(VGA_R),
		.vga_green						(VGA_G),
		.vga_blue						(VGA_B)
	 );

	 
	 //CONTROL LOGIC
	 //===================================================
	 

	DFlipFlopWithAclr delay(
		.clock 		(clk_25Mhz),
		.reset 		(reset),
		.d				(calc_rdy), 
		.q 			(calc_start)
	);
	 
	 
	 
	 
	 
	 
	 
	integer i, j;
	always @(posedge clk_25Mhz) begin
		if (reset) begin
			complete <= 0;
		
			for (i = 0; i < H_ACTIVE; i = i + 1) begin
				for (j = 0; j < V_ACTIVE; j = j + 1) begin
					display_buffer[i][j]	<= 9'd0;
					$display("CHECK THIS RESET HOMIE (display_pointer) = %d", display_pointer);
				end
			end
			counter_H <= 0;
			counter_V <= 0;
			i <= 0;
			j <= 0;
		end else	begin
			display_pointer =	display_buffer[i][j];
			$display("CHECK THIS HOMIE (display_pointer) = %d", display_pointer);
			
			if(i < H_ACTIVE - 1) begin
				i =	i + 1;
			end else if (j < V_ACTIVE - 1) begin
				i =	0;
				j =	j + 1;
			end else begin
				i = 0;
				j = 0;
			end
		end
		
		if(calc_out_rdy) begin
			display_buffer[counter_H][counter_V]	=	calc_result;
			$display("CHECK THIS HOMIE (calc_result) = %d", calc_result);
			
			if(counter_H < H_ACTIVE-1) begin
				counter_H =	counter_H + 1;
			end else if (counter_V < V_ACTIVE-1) begin
				counter_H =	counter_H + 1;
				counter_V =	counter_V + 1;
			end else begin
				complete <= 1;
			end
		end
	end
 
	 //===================================================
	 //CONTROL LOGIC

endmodule
