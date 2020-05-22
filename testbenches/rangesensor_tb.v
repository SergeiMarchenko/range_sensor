`timescale 1ns / 1ps



module rangesensor_tb;

   parameter c_CLOCK_PERIOD_NS = 20;
	// Inputs
	reg clk;
	reg rx;
	reg [1:0] echo;

	// Outputs
	wire tx;
	wire [1:0] trigger;
	wire [13:0] segments;
	wire [7:0] digit_num;

	// Instantiate the Unit Under Test (UUT)
	rangesensor uut (
		.clk(clk), 
		.rx(rx), 
		.echo(echo), 
		.tx(tx), 
		.trigger(trigger), 
		.segments(segments), 
		.digit_num(digit_num)
	);
   
   always
    #(c_CLOCK_PERIOD_NS/2) clk <= !clk;
    
    
	initial begin
		// Initialize Inputs
		clk = 0;
		rx = 0;
		echo = 0;
	end
      
endmodule

