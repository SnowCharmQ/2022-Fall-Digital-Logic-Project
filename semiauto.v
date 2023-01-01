`timescale 1ns / 1ps

module semiauto(input power, input [1:0] global_state, input [3:0] detector, 
input[1:0] state, input rst, input sys_clk, input turn_left, 
input turn_right, input go_straight, input go_back, 
output reg [1:0] next_state, output reg [3:0] next_moving_state,
output reg move_backward_light, output reg move_forward_light, 
output reg turn_left_light, output reg turn_right_light);
 
  parameter s1=2'b00, s2=2'b01, s3=2'b10, s4=2'b11;
  //s1 move forward
  //s2 waiting
  //s3 turing
  //s4 cooldown
  parameter MOVE_FORWARD=4'b0001, STOP=4'b0000, TURN_LEFT=4'b0100, TURN_RIGHT=4'b1000;
  
  reg crossroad, type;
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
    if (turn_left && ~turn_right && ~go_straight && ~go_back) traffic = TURN_LEFT;
    else if (~turn_left && turn_right && ~go_straight && ~go_back) traffic = TURN_RIGHT;
    else if (~turn_left && ~turn_right && go_straight && ~go_back) traffic = MOVE_FORWARD;
    else if (~turn_left && ~turn_right && ~go_straight && go_back) traffic = TURN_RIGHT;
    else traffic = STOP;
    if (traffic == TURN_RIGHT && go_back) type = 1'b1;
    else type = 1'b0;
  end

  always @(power, global_state, state) begin
    if (power == 1'b1 && (global_state == 2'b01 || global_state == 2'b10)) begin
      case (state)
        s1:begin
          case (crossroad)
            1'b0: begin
              next_state = s1;
              next_moving_state = MOVE_FORWARD;
            end
            1'b1: begin
              next_state = s2;
              next_moving_state = STOP;
            end
          endcase
        end 
        s2:begin
          case (traffic)
            MOVE_FORWARD: begin
              next_state = s1;//TODO: cooldown
              next_moving_state = MOVE_FORWARD;
            end
            TURN_LEFT: begin
              next_state = s3;
              next_moving_state = TURN_LEFT;
            end
            TURN_RIGHT: begin
              next_state = s3;
              next_moving_state = TURN_RIGHT;
            end
            STOP: begin
              next_state = s2;
              next_moving_state = STOP;
            end
          endcase
        end
      endcase
    end
  end


endmodule