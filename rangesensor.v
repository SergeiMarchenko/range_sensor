module rangesensor #(parameter DEVICES = 2)
(
                   input  wire                   clk,
                   input  wire                   rx, 
                   input  wire [DEVICES-1:0]     echo,
                   output wire                   tx,
                   output wire [DEVICES-1:0]     trigger,
                   output wire [DEVICES*7-1:0]   segments,
                   output wire [DEVICES*4-1:0]   digit_num
);

wire[DEVICES*4-1:0] digit1;
wire[DEVICES*4-1:0] digit2;
wire[DEVICES*4-1:0] digit3;
wire[DEVICES*4-1:0] digit4;

wire[DEVICES*8-1:0] range;
reg rst;
reg [3:0]rst_delay = 0;
always @(posedge clk)
	rst_delay <= { rst_delay[2:0], 1'b1 };
 
always @*
  rst = ~rst_delay[3];



uart #(.DEVICES(DEVICES)) uart_inst(
                           .clk(clk),
                           .rx(rx), 
                           .tx(tx),
                           .data_send(range));

genvar i;
generate 
    for (i = 0; i < DEVICES; i = i + 1) begin : loopname
      ranging_module pulse_num(clk,
                               echo[i],
                               rst,
                               trigger[i],
                               digit1[(i+1)*4-1:i*4],
                               digit2[(i+1)*4-1:i*4],
                               digit3[(i+1)*4-1:i*4],
                               digit4[(i+1)*4-1:i*4],
                               range[(i+1)*8-1:i*8]);
                               
      indicator indicator(clk,
                          digit1[(i+1)*4-1:i*4],
                          digit2[(i+1)*4-1:i*4],
                          digit3[(i+1)*4-1:i*4],
                          digit4[(i+1)*4-1:i*4],
                          segments[(i+1)*7-1:i*7],
                          digit_num[(i+1)*4-1:i*4]);
    end
endgenerate  
//ranging_module pulse_num(clk, echo, rst, trigger, digit1, digit2, digit3, digit4);
//indicator indicator(clk, digit1, digit2, digit3, digit4, segments, digit_num);         
endmodule


module ranging_module(
                    input wire       clk,
                    input wire       echo,
                    input wire       rst,
                    output reg       trigger,
                    output wire      digit1,
                    output wire[3:0] digit2,
                    output wire[3:0] digit3,
                    output wire[3:0] digit4,
                    output wire[7:0] range
);

parameter [1:0] START          = 2'b00,
                TRIG           = 2'b01,
                ECHO_LISTENING = 2'b11,
                ECHO_COUNT     = 2'b10;
               
reg[1:0] state;
reg[26:0] counter;
reg[7:0] pulse_width;
reg[8:0] pulse_counter;
reg[7:0] cm_counter;
reg       enable_count;


reg [8:0] clock_reg2;
initial clock_reg2 = 9'b0;
 
reg [3:0] digit1_reg;
initial digit1_reg = 4'd0;

reg [3:0] digit2_reg;
initial digit2_reg = 4'd0;

reg [3:0] digit3_reg;
initial digit3_reg = 4'd0;

reg [3:0] digit4_reg;
initial digit4_reg = 4'd0;

reg [3:0] cnt1;
initial cnt1 = 4'd0;

reg [3:0] cnt2;
initial cnt2 = 4'd0;

reg [3:0] cnt3;
initial cnt3 = 4'd0;

reg [3:0] cnt4;
initial cnt4 = 4'd0;


always @(posedge clk)
begin
   if (rst) begin
      pulse_counter <= 1'b0;
      cm_counter <= 1'b0;
   end
   else if (enable_count == 1'b1) begin
      pulse_counter <= pulse_counter + 1'b1;
      if(pulse_counter == 9'b1_0010_0100) // 1 cm
         cm_counter <= cm_counter + 1'b1;
   end
   else begin
      pulse_counter <= 'b0;
      cm_counter <= 1'b0;
   end
   
   if(rst)
      begin
         counter <= 1'b0;
         trigger <= 1'b0;
         state <= START;
      end
   else if(counter != 0)
      counter <= counter - 1'b1;
      
  case(state)
  START:
   begin
      pulse_counter <= 1'b0;
      enable_count <= 1'b0;
      counter <= 23'b100_1100_0100_1011_0100_0000; //100ms
      state <= TRIG;
   end
  TRIG:
   begin
      if(counter == 0)
         begin
            trigger <= 1'b1;
            counter <= 10'b10_1110_1110;//10us trig pulse 
            state <= ECHO_LISTENING;
         end
   end
  ECHO_LISTENING:
   begin
      if(counter == 0)
         begin
            trigger <= 1'b0;
            if(prev_echo == 1'b0 && echo == 1'b1)
            begin
               counter <= 23'b100_1100_0100_1101_1010_0000;
               state <= ECHO_COUNT;
            end
         end
   end
      
      
  ECHO_COUNT:
   begin
      enable_count <= 1'b1;
      if(prev_echo == 1'b1 && echo == 1'b0)
         begin
            pulse_width <= cm_counter;
            state <= START;
         end
      else if(counter == 0)
         state <= START;
   end  
   
  default:
   begin
      enable_count <= 1'b0;
      trigger <= 1'b0;
      state <= START;
   end
  endcase
  end
  
  
reg prev_echo;
always @(posedge clk)
begin
    prev_echo <= echo;
end


always @(posedge clk)
begin
   clock_reg2 <= clock_reg2 + 1'b1;
   if(prev_echo == 1'b0 && echo == 1'b1)
   begin
      clock_reg2 <= 9'b0;
      cnt1 <= 4'd0;
      cnt2 <= 4'd0;
      cnt3 <= 4'd0;
      cnt4 <= 4'd0;
   end
 if(clock_reg2 == 9'b100100100) 
 begin
     clock_reg2 <= 9'b0;
     if(cnt1 != 9) begin
      cnt1 <= cnt1 + 1'd1;
     end 
     else if(cnt2 != 9) begin
       cnt1 <= 1'd0;
       cnt2 <= cnt2 + 1'd1;
     end
     else if(cnt3 != 9) begin
       cnt2 <= 1'd0;
       cnt3 <= cnt3 + 1'd1;
     end
     else begin
       cnt3 <= 1'd0;
       cnt4 <= cnt4 + 1'd1;
      end
end
 
if(prev_echo == 1'b1 && echo == 1'b0)
 begin
   digit1_reg <= cnt1;
   digit2_reg <= cnt2;
   digit3_reg <= cnt3;
   digit4_reg <= cnt4;
 end
end

assign digit1 = digit1_reg;
assign digit2 = digit2_reg;
assign digit3 = digit3_reg;
assign digit4 = digit4_reg;

assign range = pulse_width;
endmodule




module indicator(input wire clock,
                 input wire[3:0] digit1,
                 input wire[3:0] digit2,
                 input wire[3:0] digit3,
                 input wire[3:0] digit4,
                 output wire[6:0] segments,
                 output wire[3:0] digit_num
);
      
       
reg[6:0] segments_reg;

initial segments_reg = 7'b0000000;
assign segments = segments_reg;

reg [15:0] div;                 
reg strob_100hz; 

reg[3:0]data; 
initial data = 4'd6;

reg[3:0] digit_num_reg;
initial digit_num_reg = 4'b0111;
assign digit_num = digit_num_reg;

wire [3:0] digits[4:0];

assign digits[0] = digit1;
assign digits[1] = digit2;
assign digits[2] = digit3;
assign digits[3] = digit4;


always @ (posedge clock) begin
    if (strob_100hz) begin
        digit_num_reg <= {digit_num_reg [2:0], digit_num_reg[3]};
    end
end
  
always @(posedge clock) begin
  case(data)
   4'd0:  segments_reg <= 7'b0111111;
   4'd1:  segments_reg <= 7'b0000110;
   4'd2:  segments_reg <= 7'b1011011;
   4'd3:  segments_reg <= 7'b1001111;
   4'd4:  segments_reg <= 7'b1100110;
   4'd5:  segments_reg <= 7'b1101101;
   4'd6:  segments_reg <= 7'b1111101;
   4'd7:  segments_reg <= 7'b0000111;
   4'd8:  segments_reg <= 7'b1111111;
   4'd9:  segments_reg <= 7'b1101111;
  endcase
end

always @ (posedge clock) begin
    if (div == 50000) begin
        div <= 0;
        strob_100hz <= 1'b1;
    end else begin
        strob_100hz <= 1'b0;
        div <= div+ 1'b1;
    end
end

reg[2:0] i;
always @ (posedge clock)
begin
        for (i=1'b0; i<3'd4; i=i+1'b1) begin
            if (!digit_num_reg[i]) begin
               data <= digits[i];
            end
         end
end

endmodule

