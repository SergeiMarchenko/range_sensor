`timescale 1ns / 1ps



module transmitter_tb;
   
   parameter c_CLOCK_PERIOD_NS = 20;
   parameter c_CLKS_PER_BIT    = 5208;
   parameter c_BIT_PERIOD      = 104167;
   
	// Inputs
	reg clk        = 0;
	reg enable     = 0;
	reg [7:0] data = 0;

	// Outputs
	wire tx;
	wire done;

	// Instantiate the Unit Under Test (UUT)
	transmitter #(.CLKS_PER_BIT(c_CLKS_PER_BIT)) uut (
		.clk(clk), 
		.enable(enable), 
		.data(data), 
		.tx(tx), 
		.done(done)
	);
   
   
   always
    #(c_CLOCK_PERIOD_NS/2) clk <= !clk;
    
   
   always @(posedge clk)
      if(done == 1)
         enable <= 0;
         
         
	initial begin
      @(posedge clk);
		@(posedge clk);
      enable <= 1'b1;
      data     <= 8'hAB;
      @(posedge clk);
   
	end
      
endmodule

