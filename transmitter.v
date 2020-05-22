
// Set Parameter CLKS_PER_BIT as follows:
// CLKS_PER_BIT = (Frequency of i_Clock)/(Frequency of UART)
// Example: 10 MHz Clock, 115200 baud UART
// (10000000)/(115200) = 87
module transmitter#(parameter CLKS_PER_BIT = 87)
  (
   input       clk,
	input       enable,
   input [7:0] data, 
   output reg  tx,
   output      done
   );
   
	parameter IDLE      = 3'b000,
             START_BIT = 3'b001,
             DATA_BITS = 3'b010,
				 STOP_BIT  = 3'b011,
				 CLEANUP   = 3'b100;
             
   reg [2:0]    state     = 3'b0;
   reg [31:0]   clk_count = 8'b0;
   reg [2:0]    bit_indx  = 3'b0;
   reg [7:0]    data_reg  = 8'b0;
   reg          done_reg  = 1'b0;


   assign done = done_reg;
   
    
   always @(posedge clk)
    begin
       
      case (state)
        IDLE:
          begin
            tx        <= 1'b1;         // Drive Line High for Idle
            done_reg  <= 1'b0;
            clk_count <= 0;
            bit_indx  <= 0;
             
            if (enable == 1'b1)
              begin
                data_reg   <= data;
                state      <= START_BIT;
              end
            else
              state <= IDLE;
          end // case: IDLE
         
         
        // Send out Start Bit. Start bit = 0
        START_BIT:
          begin
            tx <= 1'b0;
             
            // Wait CLKS_PER_BIT-1 clock cycles for start bit to finish
            if (clk_count < CLKS_PER_BIT-1)
              begin
                clk_count <= clk_count + 1;
                state     <= START_BIT;
              end
            else
              begin
                clk_count <= 0;
                state <= DATA_BITS;
              end
          end // case: TX_START_BIT
         
         
        // Wait CLKS_PER_BIT-1 clock cycles for data bits to finish         
        DATA_BITS:
          begin
            tx <= data_reg[bit_indx];
             
            if (clk_count < CLKS_PER_BIT-1)
              begin
                clk_count <= clk_count + 1;
                state     <= DATA_BITS;
              end
            else
              begin
                clk_count <= 1'b0;
                 
                // Check if we have sent out all bits
                if (bit_indx < 7)
                  begin
                    bit_indx <= bit_indx + 1'b1;
                    state    <= DATA_BITS;
                  end
                else
                  begin
                    bit_indx <= 0;
                    state    <= STOP_BIT;
                  end
              end
          end // case: DATA_BITS
         
         
        // Send out Stop bit.  Stop bit = 1
        STOP_BIT:
          begin
            tx <= 1'b1;
             
            // Wait CLKS_PER_BIT-1 clock cycles for Stop bit to finish
            if (clk_count < CLKS_PER_BIT-1)
              begin
                clk_count <= clk_count + 1;
                state     <= STOP_BIT;
              end
            else
              begin
                done_reg     <= 1'b1;
                clk_count    <= 0;
                state        <= CLEANUP;
              end
          end // case: STOP_BIT
         
         
        // Stay here 1 clock
        CLEANUP:
          begin
            done_reg <= 1'b0;
            state    <= IDLE;
          end
         
         
        default :
          state <= IDLE;
         
      endcase
    end
endmodule
