/*
 * VGADriver
 * ----------------
 * By: Shrawan Sreekumar
 * For: Group 33, ELEC5566M
 * Date: 01/05/2024
 *
 * Description
 * -----------
 * The module is used as a IP block to drive the VGA peripheral
 *	in the DE1-SoC.
 * 
 */
module VGADriver (
    input wire clk,  // 25 MHz
    input wire reset,
	 
    input [4:0] red_in, 
    input [4:0] green_in, 
    input [4:0] blue_in,

//    output [9:0] x,  // next x pixel
//    output [9:0] y,  // next y pixel

    output vga_sync,
    output vga_clk,
    output vga_blank,
    output wire hsync,
    output wire vsync,

    output [7:0] vga_red, 
    output [7:0] vga_green, 
    output [7:0] vga_blue
);

	// Horizontal parameters (measured in clock cycles)
	parameter H_ACTIVE	= 639;// Active video horizontal length
	parameter H_FRONT		= 15;	// Horizontal front porch length
	parameter H_PULSE		= 95;	// Horizontal sync pulse width
	parameter H_BACK		= 47;	// Horizontal back porch length

	// Vertical parameters (measured in lines)
	parameter V_ACTIVE	= 479;// Active video vertical height
	parameter V_FRONT		= 9;	// Vertical front porch length
	parameter V_PULSE		= 1;	// Vertical sync pulse width
	parameter V_BACK		= 32;	// Vertical back porch length
	
    // Internal registers for output and state
    reg hsync_reg, vsync_reg;
    reg [7:0] red_reg, green_reg, blue_reg;
    reg [9:0] h_counter, v_counter;
    reg [7:0] h_state, v_state;
    reg show;

	// Main VGA control process
	always @(posedge clk) begin
		if (reset)	begin
			// Initialize registers on reset
			h_counter <= 0;
			v_counter <= 0;
			
			h_state <= 8'd0;
			v_state <= 8'd0;
			
			show <= 1'b0;
			hsync_reg <= 1'b0;
			vsync_reg <= 1'b0;
			
			red_reg	<= 0;
			green_reg<= 0;
			blue_reg	<= 0;
		end
		else	begin
			// Process horizontal states
			process_horizontal_state();
			// Process vertical states
			process_vertical_state();
			// Assign colors based on current state
			assign_colors();
		end
	end

    // Separate tasks for clarity
    task process_horizontal_state;
        begin
            case (h_state)
                8'd0:	h_active();
                8'd1:	h_front();
                8'd2:	h_pulse();
                8'd3:	h_back();
            endcase
        end
    endtask

    task process_vertical_state;
        begin
            if (show == 1'b1) begin
                case (v_state)
                    8'd0:	v_active();
                    8'd1:	v_front();
                    8'd2:	v_pulse();
                    8'd3:	v_back();
                endcase
            end
        end
    endtask

    task h_active;
        begin
            h_counter <= (h_counter == H_ACTIVE) ? 0 : h_counter + 1;
            hsync_reg <= 1'b1;
            h_state <= (h_counter == H_ACTIVE) ? 8'd1 : 8'd0;
        end
    endtask

    task h_front;
        begin
            h_counter <= (h_counter == H_FRONT) ? 0 : h_counter + 1;
            hsync_reg <= 1'b1;
            h_state <= (h_counter == H_FRONT) ? 8'd2 : 8'd1;
        end
    endtask

    task h_pulse;
        begin
            h_counter <= (h_counter == H_PULSE) ? 0 : h_counter + 1;
            hsync_reg <= 1'b0;
            h_state <= (h_counter == H_PULSE) ? 8'd3 : 8'd2;
        end
    endtask

    task h_back;
        begin
            h_counter <= (h_counter == H_BACK) ? 0 : h_counter + 1;
            hsync_reg <= 1'b1;
            h_state <= (h_counter == H_BACK) ? 8'd0 : 8'd3;
            show <= (h_counter == (H_BACK - 1)) ? 1'b1 : 1'b0;
        end
    endtask

    task v_active;
        begin
            v_counter <= (v_counter == V_ACTIVE) ? 0 : v_counter + 1;
            vsync_reg <= 1'b1;
            v_state <= (v_counter == V_ACTIVE) ? 8'd1 : 8'd0;
        end
    endtask

    task v_front;
        begin
            v_counter <= (v_counter == V_FRONT) ? 0 : v_counter + 1;
            vsync_reg <= 1'b1;
            v_state <= (v_counter == V_FRONT) ? 8'd2 : 8'd1;
        end
    endtask

    task v_pulse;
        begin
            v_counter <= (v_counter == V_PULSE) ? 0 : v_counter + 1;
            vsync_reg <= 1'b0;
            v_state <= (v_counter == V_PULSE) ? 8'd3 : 8'd2;
        end
    endtask

    task v_back;
        begin
            v_counter <= (v_counter == V_BACK) ? 0 : v_counter + 1;
            vsync_reg <= 1'b1;
            v_state <= (v_counter == V_BACK) ? 8'd0 : 8'd3;
        end
    endtask


    task assign_colors;
        if (h_state == 8'd0 && v_state == 8'd0) begin
            red_reg   <= {red_in, 3'b111};
            green_reg <= {green_in, 3'b111};
            blue_reg  <= {blue_in, 3'b111};
        end else begin
            red_reg <= 0; green_reg <= 0; blue_reg <= 0;
        end
    endtask

    // Continuous assignments for VGA output signals
    assign hsync = hsync_reg;
    assign vsync = vsync_reg;
    assign vga_red = red_reg;
    assign vga_green = green_reg;
    assign vga_blue = blue_reg;
    assign vga_clk = clk;
    assign vga_sync = 1'b0;
    assign vga_blank = hsync_reg && vsync_reg;
//    assign x = (h_state == 8'd0) ? h_counter : 10'd0;
//    assign y = (v_state == 8'd0) ? v_counter : 10'd0;

endmodule
