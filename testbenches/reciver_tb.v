`timescale 1ns / 1ps



module reciver_tb;
   parameter c_CLOCK_PERIOD_NS = 20;
   parameter c_CLKS_PER_BIT    = 5208;
   parameter c_BIT_PERIOD      = 104167;
	// Inputs
	reg clk = 0;
	reg rx = 1;

	// Outputs
	wire done;
	wire [7:0] data;
  
  
   reg[7:0] in_data;
   integer ii = 0;
	// Instantiate the Unit Under Test (UUT)
	reciver #(.CLKS_PER_BIT(c_CLKS_PER_BIT)) uut 
   (
		.clk(clk), 
		.rx(rx), 
		.done(done), 
		.data(data)
	);

always
    #(c_CLOCK_PERIOD_NS/2) clk <= !clk;
    
	initial begin
      in_data <= 8'b01010101;
      
		// Send Start Bit
      rx <= 1'b0;
      #(c_BIT_PERIOD);
      #1000;
       
       
      // Send Data Byte
      rx <= in_data[0];
      #(c_BIT_PERIOD);
        
      rx <= in_data[1];
      #(c_BIT_PERIOD);

      rx <= in_data[2];
      #(c_BIT_PERIOD);           
      
      rx <= in_data[3];
      #(c_BIT_PERIOD);
      
      rx <= in_data[4];
      #(c_BIT_PERIOD);
      
      rx <= in_data[5];
      #(c_BIT_PERIOD);
      
      rx <= in_data[6];
      #(c_BIT_PERIOD);
      
      rx <= in_data[7];
      #(c_BIT_PERIOD);
      
  
      // Send Stop Bit
      rx <= 1'b1;
      #(c_BIT_PERIOD);
      
      #1000000;

      in_data <= 8'b01110101;
		// Send Start Bit
      rx <= 1'b0;
      #(c_BIT_PERIOD);
      #1000;
       
       
      // Send Data Byte
      rx <= in_data[0];
      #(c_BIT_PERIOD);
        
      rx <= in_data[1];
      #(c_BIT_PERIOD);

      rx <= in_data[2];
      #(c_BIT_PERIOD);           
      
      rx <= in_data[3];
      #(c_BIT_PERIOD);
      
      rx <= in_data[4];
      #(c_BIT_PERIOD);
      
      rx <= in_data[5];
      #(c_BIT_PERIOD);
      
      rx <= in_data[6];
      #(c_BIT_PERIOD);
      
      rx <= in_data[7];
      #(c_BIT_PERIOD);
      
      // Send Stop Bit
      rx <= 1'b1;
      #(c_BIT_PERIOD);
	end
      
endmodule

