`timescale 1ns / 1ps

module semi_auto(input power, input [1:0] global_state, input [3:0] detector, 
input[1:0] state, input rst, input sys_clk, input turn_left, input turn_right, 
input go_straight, input go_back, output reg [1:0] next_state, output reg [3:0] next_moving_state,
output reg move_backward_light, output reg move_forward_light, 
output reg turn_left_light, output reg turn_right_light);
 
  parameter s1=2'b00, s2=2'b01, s3=2'b10, s4=2'b11;
  //s1 move forward
  //s2 waiting
  //s3 turing
  //s4 cooldown
  parameter ns1=4'b0001, ns2=4'b0000, ns3=4'b0100, ns4=4'b1000;
  //ns1 move forward
  //ns2 stop
  //ns3 turn left
  //ns4 turn right
  
  reg crossroad;
  reg [1:0] next_turn;
  reg [1:0] turn;
  reg type, next_type;
  reg [10:0] turn_cnt;
  reg [10:0] cool_cnt;
  reg [3:0] traffic;
  wire clk_ms,clk_20ms,clk_16x,clk_x;
  divclk myclk(sys_clk,clk_ms,clk_20ms,clk_16x,clk_x);

  always @(detector) begin
    if (detector[0] || ~detector[1] || ~detector[2]) crossroad = 1'b1;
    else crossroad = 1'b0;
  end

  always @(turn_left,turn_right,go_straight,go_back) begin
      if (turn_left && ~turn_right && ~go_straight && ~go_back) traffic = 4'b1000;
      else if (~turn_left && turn_right && ~go_straight && ~go_back) traffic = 4'b0100;
      else if (~turn_left && ~turn_right && go_straight && ~go_back) traffic = 4'b0010;
      else if (~turn_left && ~turn_right && ~go_straight && go_back) traffic = 4'b0001;
      else traffic = 4'b0000;
      case({turn_left,turn_right,go_straight,go_back})
        4'b1000:turn = 2'b10;
        4'b0100:turn = 2'b01;
        4'b0010:turn = 2'b00;
        4'b0001:turn = 2'b01;
        default turn = 2'b00;
      endcase
      case({turn_left,turn_right,go_straight,go_back})
        4'b0001: type = 1'b1;
        default type = 1'b0;
      endcase  
  end

  always@(posedge clk_20ms) begin
    if (rst == 1'b1)
      begin
      cool_cnt <= 11'b0;
      turn_cnt <= 11'b0;
      end
    else 
    begin
      if(state == s4)
        cool_cnt <= cool_cnt + 11'b1;
      else
        cool_cnt <= 11'b0;
      if(state == s3)
        turn_cnt <= turn_cnt + 11'b1;
      else
        turn_cnt <= 11'b0;
      end
  end
  
  always@(power, global_state, traffic, turn, type, turn_cnt, cool_cnt, crossroad) begin

  if (power == 1'b1 && (global_state == 2'b01 || global_state == 2'b10)) begin
    
    case(state)
    s1://semi_moving
    begin
      next_turn = 2'b00;
      next_type = 1'b0;
      if (crossroad == 1'b0) begin
        next_state = s1;
        next_moving_state = ns1;
      end
      else begin
        next_state = s2;
        next_moving_state = ns2;
      end
    end

    s2://waiting
      if (traffic == 4'b1000) begin
        next_type = 1'b0;
        next_turn = 2'b10;
        next_state = s3;
        next_moving_state = ns3;
      end
      else if (traffic == 4'b0100) begin
        next_type = 1'b0;
        next_turn = 2'b01;
        next_state = s3;
        next_moving_state = ns4;
      end
      else if (traffic == 4'b0010) begin
        next_type = 1'b0;
        next_turn = 2'b00;
        next_state = s4;
        next_moving_state = ns1;
      end
      else if (traffic == 4'b0001) begin
        next_type = 1'b1;
        next_turn = 2'b01;
        next_state = s3;
        next_moving_state = ns4;
      end
      else begin
        next_turn = turn;
        next_type = type;
        next_state = s2;
        next_moving_state = ns2;
      end
    
    s3://turning
    begin
      next_type = type;
      next_turn = turn;
      case(type)
      1'b1:
      begin
        if(turn_cnt >= 11'd400)
          begin
            next_state = s4;
            next_moving_state = ns1;
          end
        else
          begin
            next_state = s3;
            next_moving_state = ns3;
          end
      end
      
      1'b0:
      begin
        if(turn_cnt >= 11'd200)
          begin
            next_state = s4;
            next_moving_state = ns1;
          end
        else 
          begin
            next_state = s3;
            if (turn == 2'b10) next_moving_state = ns3;
            else next_moving_state = ns4;
          end
      end
      endcase
    end
  
    s4://cooldown
    begin
      next_type = 1'b0;
      next_turn = 2'b00;
      if(cool_cnt >= 11'd10)
        begin
          next_state = s1;
          next_moving_state = ns1;
        end
      else begin
        next_state = s4;
        next_moving_state = ns1;
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