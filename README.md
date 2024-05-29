
# ELEC5566M - FPGA Design for System-on-chip
## Assessment 2 : ELEC5566M Mini-Project Repository

This repository contains the Intel Quartus Project, as well as the Verilog files created to design, simulate and test the Mandelbrotset module.

## Acknowledgements

 - [Resources for ELEC5566M](https://github.com/leeds-embedded-systems/ELEC5566M-Resources) - for supplying the TCL files required for ModelSim Simulation.


## Authors

- [@shrawansree](https://github.com/shrawansree)
- [@TheOneRui](https://github.com/TheOneRui)
- [@RhettMews](https://github.com/RhettMews)
- [@dcowell](https://github.com/dcowell)
- [@TCWORLD](https://github.com/TCWORLD)
- [@harryclegg](https://github.com/harryclegg)

## Documentation

The following files are provided in the repository:

| File | Purpose |
| ---  | --- |
| `Mandelbrotset.v`	| Top-level module for this project |
| `MandelbrotCalculator.v` 	|	Calculates numbers in the mandelbrot set |
| `Pipe.v`		|  Pipeline to wrap MandelbrotCalculator and FiFo's |
| `FiFo.v`		| Synchronous first in first out queue implementation |
| `VGADriver.v`	| DE1-SoC VGA Driver |
| `AddressMapper.v`       | Maps VGA pixels to decimals |


### [Mandelbrotset.v](https://github.com/leeds-embedded-systems/ELEC5566M-Mini-Project-Group-33/blob/main/MandelbrotSet.v) 

| Ports | Purpose |
| ---  | --- |
| `clk`		| 50MHz Clock from DE1-SoC Board	|
| `reset`	| User reset signal input			|
| `VGA_HS`	| VGA HSYNC Output Signal	|
| `VGA_VS`	| VGA VSYNC Output Signal	|
| `VGA_R`	| VGA Red Colour Output Signal	|
| `VGA_G`	| VGA Blue Colour Output Signal	|
| `VGA_B`	| VGA Green Colour Output Signal|
| `VGA_SYNC`	| VGA SYNC Output Signal	|
| `VGA_CLK`		| 25MHz VGA Driver Clock Output Signal	|
| `VGA_BLANK`	| VGA BLANK Output Signal	|



#### Usage/Examples

```verilog
// Inputs signals
reg clk;
reg reset;

// Outputs signals
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

```

### [MandelbrotCalculator.v](https://github.com/leeds-embedded-systems/ELEC5566M-Mini-Project-Group-33/blob/main/MandelbrotCalculator.v) 


| Parameters	|	Default	|  Purpose	|
| 	  ---		| 	 ---	|	---		|
| `BIT_WIDTH `		| 32	|	Bit-width of input values	|
| `MAX_ITERATIONS `	| 512	|	Maximum number of internal iterations before exit	|
| `FLOAT_PRECISION `|	24	|	Floating value precision	|


| Ports | Purpose |
| ---  | --- |
| `clk`		| 25MHz Clock from Mandelbrotset	|
| `reset`	| User reset signal input			|
| `real_part`	| Mandelbrot Calculation Real value	|
| `imaginary_part`	| Mandelbrot Calculation Imaginary value	|
| `start`	| Start Calculation input signal	|
| `out_ready`	| Output flag to alert when Calculation is complete	|
| `colour_data`	| Output signal (pixel colour)	|
| `ready_for_input`	| Output flag to alert availability for input	|



#### Usage/Examples

```verilog
// Inputs
reg clk, rst, start;
wire signed [BIT_WIDTH-1:0] real_part;
wire signed [BIT_WIDTH-1:0] imaginary_part;
// Outputs
wire out_ready;
wire [BIT_WIDTH-1:0] colour_data;
wire ready_for_input;
 
// Instantiate the Unit Under Test (UUT)
MandelbrotCalculator #(
	.BIT_WIDTH(BIT_WIDTH),
	.MAX_ITERATIONS(512),
	.FLOAT_PRECISION(24)
) uut (
	.clk(clk),
	.rst(rst),
	.real_part(real_part),
	.imaginary_part(imaginary_part),
	.start(start),
	.out_ready(out_ready),
	.colour_data(colour_data),
	.ready_for_input(ready_for_input)
);
```

### [Pipe.v](https://github.com/leeds-embedded-systems/ELEC5566M-Mini-Project-Group-33/blob/main/Pipe.v)


| Parameters	|	Default	|  Purpose	|
| 	  ---		| 	 ---	|	---		|
| `N `	|	16	|	Number of pipes	|
| `BIT_WIDTH `		| 32	|	Bit-width of input values	|
| `MAX_ITERATIONS `	| 512	|	Maximum number of internal iterations before exit	|
| `FLOAT_PRECISION `|	24	|	Floating value precision	|


| Ports | Purpose |
| ---  | --- |
| `clk`		| 25MHz Clock from Mandelbrotset	|
| `reset`	| User reset signal input			|
| `w_cntrl_real`	| Write control input for real number	|
| `w_cntrl_imag`	| Write control input for imaginary_part number	|
| `r_cntrl`	| Read control input for output value	|
| `data_in_real`	| Data real value input	|
| `data_in_imag`	| Data imaginary value input	|
| `data_out`	|	Data output (pixel colour value)|
| `full_real`	|	FiFo Flag to indicate Real values full	|
| `full_imag`	|	FiFo Flag to indicate Imaginary values full	|
| `empty `	|	Active when FiFo is empty	|


#### Usage/Examples

```verilog
parameter BIT_WIDTH = 32;
parameter TEST_DURATION = 1000; // Duration of the test in clock cycles

// Inputs
reg clk;
reg rst;
reg w_cntrl_real;
reg w_cntrl_imag;
reg r_cntrl;
reg [BIT_WIDTH-1:0] data_in_real;
reg [BIT_WIDTH-1:0] data_in_imag;

// Outputs
wire [BIT_WIDTH-1:0] data_out;
wire full_real;
wire full_imag;
wire empty;

// Instantiate the Unit Under Test (UUT)
Pipe #(
	.N(16),
	.BIT_WIDTH(BIT_WIDTH),
	.MAX_ITERATIONS(512),
	.FLOAT_PRECISION(26)
) uut (
	.clk(clk),
	.rst(rst),
	.w_cntrl_real(w_cntrl_real),
	.w_cntrl_imag(w_cntrl_imag),
	.r_cntrl(r_cntrl),
	.data_in_real(data_in_real),
	.data_in_imag(data_in_imag),
	.data_out(data_out),
	.full_real(full_real),
	.full_imag(full_imag),
	.empty(empty)
);
```


### [FiFo.v](https://github.com/leeds-embedded-systems/ELEC5566M-Mini-Project-Group-33/blob/main/FiFo.v)


| Parameters	|	Default	|  Purpose	|
| 	  ---		| 	 ---	|	---		|
| `N `	|	16	|	Number of pipes	|
| `BIT_WIDTH `		| 32	|	Bit-width of input values	|


| Ports | Purpose |
| ---  | --- |
| `clk`		|	25MHz Clock from Mandelbrotset	|
| `reset`	|	User reset signal input			|
| `w_cntrl`	|	Write control input	|
| `r_cntrl`	|	Read control input for output value	|
| `data_in`	|	Data value input	|
| `data_out`|	Data output	|
| `full`	|	FiFo Flag to indicate values are full	|
| `empty `	|	Active when FiFo is empty	|


#### Usage/Examples

```verilog
reg clk, rst;
reg w_cntrl;
reg r_cntrl;
reg [BIT_WIDTH-1:0] data_in;
wire [BIT_WIDTH-1:0] data_out;
wire full;
wire empty;

// Queue to push data_in
reg [BIT_WIDTH-1:0] storage[320:0];
reg [BIT_WIDTH-1:0] compare_var;

FiFo #(.BIT_WIDTH (BIT_WIDTH))DUT(
	.clk (clk), 
	.rst (rst), 
	.w_cntrl (w_cntrl),
	.r_cntrl (r_cntrl), 
	.data_in (data_in), 
	.data_out (data_out), 
	.full (full), 
	.empty (empty)
);
```

### [AddressMapper.v](https://github.com/leeds-embedded-systems/ELEC5566M-Mini-Project-Group-33/blob/main/AddressMapper.v)


| Parameters	|	Default	|  Purpose	|
| 	  ---		| 	 ---	|	---		|
| `FLOAT_PRECISION `|	24	|	Floating value precision	|
| `MAX_X`	|	64	|	Maximum X Value	|
| `MAX_Y `	|	48	|	Maximum Y Value	|


| Ports | Purpose |
| ---  | --- |
| `clk`		|	25MHz Clock from Mandelbrotset	|
| `reset`	|	User reset signal input			|
| `mapped_x`	|	Mapped x value output	|
| `mapped_y`	|	Mapped y value output	|


#### Usage/Examples

```verilog
parameter FLOAT_PRECISION = 24;
parameter MAX_X = 64;
parameter MAX_Y = 48;
reg clk;
reg rst;
wire signed [31:0] mapped_x;
wire signed [31:0] mapped_y;

AddressMapper #(
	.FLOAT_PRECISION(FLOAT_PRECISION),
	.MAX_X(MAX_X),
	.MAX_Y(MAX_Y)
) dut (
	.clk(clk),
	.rst(rst),
	.mapped_x(mapped_x),
	.mapped_y(mapped_y)
);
```

### [VGADriver.v](https://github.com/leeds-embedded-systems/ELEC5566M-Mini-Project-Group-33/blob/main/VGADriver.v)

| Ports | Purpose |
| ---  | --- |
| Ports | Purpose |
| ---  | --- |
| `clk`		| 50MHz Clock from DE1-SoC Board	|
| `reset`	| User reset signal input			|
| `hsync`	| VGA HSYNC Output Signal	|
| `vsync`	| VGA VSYNC Output Signal	|
| `red_in`	| VGA Red Colour Input Signal	|
| `green_in`	| VGA Blue Colour Input Signal	|
| `blue_in`		| VGA Green Colour Input Signal|
| `vga_sync`	| VGA SYNC Output Signal	|
| `vga_clk`		| 25MHz VGA Driver Clock Output Signal	|
| `vga_blank`	| VGA BLANK Output Signal	|
| `vga_red`		| VGA Red Colour Output Signal	|
| `vga_green`	| VGA Blue Colour Output Signal	|
| `vga_blue`	| VGA Green Colour Output Signal|

#### Usage/Examples

```verilog
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
```