module uart #(parameter DEVICES = 2)
   (
    input  wire                clk,
    input  wire                rx,
    input  wire[DEVICES*8-1:0] data_send,
    output wire                tx
    );
   
   parameter c_CLKS_PER_BIT = 5208;
   
   
   
   wire [7:0] data_rx;
	wire done_rx;
   
   reciver #(.CLKS_PER_BIT(c_CLKS_PER_BIT)) reciver_inst 
   (
		.clk(clk), 
		.rx(rx), 
		.done(done_rx), 
		.data(data_rx)
	);
   
   
   reg[7:0] data_tx;
   reg      enable;
   
	wire done_tx;
   transmitter #(.CLKS_PER_BIT(c_CLKS_PER_BIT)) transmitter_inst 
   (
		.clk(clk), 
		.enable(enable), 
		.data(data_tx), 
		.tx(tx), 
		.done(done_tx)
	);
   
  
   
   reg[2:0] i = 1'b0;
   
   always @(posedge clk)
    begin
         
         data_tx <= data_send[i*8+:8];
         enable <= 1; 
         if(done_tx)
            i <= i + 1'b1;
         
         if(i == DEVICES)
            i <= 1'b0;
    end

endmodule