`timescale 1ns / 1ps

module semi_auto(input power, input [1:0] global_state, input [3:0] detector, 
input[1:0] state, input rst,input sys_clk, input turn_left, input turn_right, 
input go_straight, input go_back, output reg [1:0] next_state, output reg [3:0] next_moving_state);
 
  parameter s1=2'b00, s2=2'b01, s3=2'b10, s4=2'b11;
  parameter ns1=4'b1000, ns2=4'b0000, ns3=4'b0100, ns4=4'b0001;
  //ns1直行，ns2停下，0100转弯，0001 cool
  
  reg next_type;
  reg [1:0] next_turn;
  reg [1:0] turn;
  reg type;
  reg keep;
  reg turn_cnt;
  reg cool_cnt;
  wire clk_ms,clk_20ms,clk_16x,clk_x;
  divclk myclk(sys_clk,clk_ms,clk_20ms,clk_16x,clk_x);
  
  always@(posedge clk_20ms, negedge rst) begin
    if(~rst)
      begin
      cool_cnt<=1'b0;
      turn_cnt<=1'b0;
      end
    else 
    begin
      if(state == s4)
        cool_cnt <= cool_cnt+1;
      else
        cool_cnt<=10'b0;
      if(state == s3)
        turn_cnt <= turn_cnt+1;
      else
        turn_cnt <= 10'b0;
      end
  end
      
  always@* begin
   if(cool_cnt >= 10'd50)
        keep = 1'b1;
    else keep = 1'b0;
  end
  
  always@* begin
  
  if (power == 1'b1 && (global_state == 2'b01 || global_state == 2'b10)) begin
  case({turn_left,turn_right,go_straight,go_back})
    4'b1000:turn = 2'b10;
    4'b0100:turn = 2'b01;
    4'b0010:turn = 2'b00;
    4'b0001:turn = 2'b01;
    default turn = 2'b00;
  endcase
  
  case({turn_left,turn_right,go_straight,go_back})
    4'b0001:type = 1'b1;
    default type = 1'b0;
  endcase  
    
  case(state)
  s1://semi_moving
  if(keep)
    begin
      if(~detector[3])
        begin
        next_state=s1;
        next_moving_state = ns1;
        end
      else 
        begin
        next_state=s2;
        next_moving_state = ns2;
        end
    end
  else
   case(detector)//前后左右
     4'b0011://直道 直行
     begin
       next_turn = 2'b00;
       next_type = 1'b0;
       next_state = s1;
       next_moving_state = ns1;
     end
     
     4'b1011://掉头
     begin
        next_turn = 2'b01;
        next_type = 1'b1;
        next_state = s3;
        next_moving_state = ns3;
     end
     
     4'b1001://左转
     begin
       next_turn = 2'b10;
       next_type = 1'b0;
       next_state = s3;
       next_moving_state = ns3;
     end
     
     4'b1010://右转
     begin
       next_turn = 2'b01;
       next_type = 1'b0;
       next_state = s3;
       next_moving_state = ns3;
     end
     
     default//默认保持不变
     begin
       next_turn = turn;
       next_type = type;
       next_state = s1;
       next_moving_state = ns1;
     end
    endcase
   
   s2://waiting
    case({turn_left,turn_right,go_straight,go_back})
      4'b1000://左转
       begin
         next_type = 1'b0;
         next_turn = 2'b10;
         next_state = s3;
         next_moving_state = ns3;
       end
       
      4'b0100://右转
       begin
         next_type = 1'b0;
         next_turn = 2'b01;
         next_state = s3;
         next_moving_state = ns3;
       end
       
      4'b0010://直行
       begin
         next_type = 1'b0;
         next_turn = 2'b00;
         next_state = s4;//cooldown
         next_moving_state = ns4;
       end
       
      4'b0001://掉头
       begin
         next_type = 1'b1;
         next_turn = 2'b01;
         next_state = s3;
         next_moving_state = ns3;
       end
       
      default
      begin
       next_turn = turn;
       next_type = type;
       next_state = s2;
       next_moving_state = ns2;
      end
    endcase
   
   s3://turning
   begin
    next_type = type;
    next_turn = turn;
    case(type)
     1'b1://掉头
     begin
       if(turn_cnt >= 10'd100)
        begin
           next_state = s4;
           next_moving_state = ns4;
        end
       else
        begin
         next_state = s3;
         next_moving_state = ns3;
       end
     end
     
     1'b0:
     begin
       if(turn_cnt >= 10'd50)
         begin
          next_state = s4;
          next_moving_state = ns4;
        end
       else 
        begin
         next_state = s3;
         next_moving_state = ns3;
        end
     end
    endcase
   end
   
   s4://cooldown
   begin
     next_type = type;
     next_turn = turn;
     if(cool_cnt >= 10'd50)//校准时间
      begin
        next_state = s1;
        next_moving_state = ns1;
       end
     else begin
       next_state = s4;
       next_moving_state = ns4;
     end
   end
  endcase
  end
  else begin
    next_state = s2;
    next_moving_state = ns2;
  end

end
         
endmodule
