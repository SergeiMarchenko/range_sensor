// Set Parameter CLKS_PER_BIT as follows:
// CLKS_PER_BIT = (Frequency of i_Clock)/(Frequency of UART)
// Example: 10 MHz Clock, 115200 baud UART
// (10000000)/(115200) = 87
module reciver #(parameter CLKS_PER_BIT = 5208)
  (
   input        clk,
   input        rx,
   output       done,
   output [7:0] data
   );

   parameter IDLE      = 3'b000,
             START_BIT = 3'b001,
             DATA_BITS = 3'b010,
				 STOP_BIT  = 3'b011,
				 CLEANUP   = 3'b100;
             
   reg   rx_rega = 1'b1;
   reg   rx_reg  = 1'b1;


   reg [2:0]    state     = 3'b0;
   reg [31:0]   clk_count = 8'b0;
   reg [2:0]    bit_indx  = 3'b0;
   reg [7:0]    data_reg  = 8'b0;
   reg          done_reg  = 1'b0;


   assign data = data_reg;
   assign done = done_reg;
   
   always @(posedge clk)
     begin
       rx_rega <= rx;
       rx_reg  <= rx_rega;
     end
     
    always @(posedge clk)
    begin
       
      case (state)
        IDLE :
          begin
            done_reg  <= 0;
            clk_count <= 0;
            bit_indx  <= 0;
             
            if (rx_reg == 1'b0)          // Start bit detected
              state <= START_BIT;
            else
              state <= IDLE;
          end
         
        // Check middle of start bit to make sure it's still low
        START_BIT :
          begin
            if (clk_count == (CLKS_PER_BIT-1)/2)
              begin
                if (rx_reg == 1'b0)
                  begin
                    clk_count <= 0;  // reset counter, found the middle
                    state     <= DATA_BITS;
                  end
                else
                  state <= IDLE;
              end
            else
              begin
                clk_count <= clk_count + 1;
                state     <= START_BIT;
              end
          end // case: START_BIT
         
         
        // Wait CLKS_PER_BIT-1 clock cycles to sample serial data
        DATA_BITS :
          begin
            if (clk_count < CLKS_PER_BIT-1)
              begin
                clk_count <= clk_count + 1;
                state     <= DATA_BITS;
              end
            else
              begin
                clk_count          <= 0;
                data_reg[bit_indx] <= rx_reg;
                 
                // Check if we have received all bits
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
          end // case: s_RX_DATA_BITS
     
     
        // Receive Stop bit.  Stop bit = 1
        STOP_BIT :
          begin
            // Wait CLKS_PER_BIT-1 clock cycles for Stop bit to finish
            if (clk_count < CLKS_PER_BIT-1)
              begin
                clk_count <= clk_count + 1;
                state     <= STOP_BIT;
              end
            else
              begin
                clk_count <= 0;
                done_reg  <= 1;
                state     <= CLEANUP;
              end
          end // case: s_RX_STOP_BIT
     
         
        // Stay here 1 clock
        CLEANUP :
          begin
            state <= IDLE;
          end
         
         
        default :
          state <= IDLE;
         
      endcase
    end 
 endmodule 