`timescale 1ns / 1ps

module semiauto(input power, input [1:0] global_state, input [3:0] detector, 
input[1:0] state, input[3:0] moving_state, input rst, input sys_clk, 
input left, input right, input straight, input back, 
output reg [1:0] next_state, output reg [3:0] next_moving_state);
 
  parameter s1=2'b01, s2=2'b00, s3=2'b10, s4=2'b11;
  //s1 move forward
  //s2 waiting
  //s3 turing
  //s4 cooldown
  parameter MOVE_FORWARD=4'b0001, STOP=4'b0000, TURN_LEFT=4'b0100, TURN_RIGHT=4'b1000;
  
  reg crossroad = 1'b1;
  reg around = 1'b0;
  reg [15:0] turn_cnt;
  reg [10:0] cool_cnt;
  reg [3:0] traffic;
  wire clk_ms,clk_20ms,clk_16x,clk_x;
  divclk myclk(sys_clk,clk_ms,clk_20ms,clk_16x,clk_x);

  always @(posedge clk_20ms) begin
    if (rst == 1'b1) begin
      turn_cnt <= 11'b0;
    end
    else begin
      if (state == s3) turn_cnt <= turn_cnt + 11'b1;
      else turn_cnt <= 11'b0;
    end
  end

  always @(posedge clk_20ms) begin
    if (rst == 1'b1) begin
      cool_cnt <= 11'b0;
    end
    else begin
      if (state == s4) cool_cnt <= cool_cnt + 11'b1;
      else cool_cnt <= 11'b0;
    end
  end

  always @(posedge sys_clk) begin
    if (detector[0] || ~detector[1] || ~detector[2]) crossroad <= 1'b1;
    else crossroad <= 1'b0;
  end

  always @(straight, back, left, right) begin
    if (straight) begin
      traffic = MOVE_FORWARD;
      around = 1'b0;
    end
    else if (back) begin
      traffic = TURN_LEFT;
      around = 1'b1;
    end
    else if (left && ~right) begin
      traffic = TURN_LEFT;
      around = 1'b0;
    end 
    else if (~left && right) begin
      traffic = TURN_RIGHT;
      around = 1'b0;
    end 
    else begin
      traffic = STOP;
      around = 1'b0;
    end 
  end

  always @(power, rst, global_state, state, moving_state, traffic, cool_cnt, turn_cnt, crossroad, around) begin
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
            default: begin
              next_state = s1;
              next_moving_state = MOVE_FORWARD;
            end
          endcase
        end 
        s2:begin
          case (traffic)
            STOP: begin
              next_state = s2;
              next_moving_state = STOP;
            end 
            MOVE_FORWARD: begin
              next_state = s4;
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
            default: begin
              next_state = s2;
              next_moving_state = STOP;
            end
          endcase
        end
        s3:begin
          case (around)
            1'b1: begin
              if (turn_cnt >= 16'd200) begin
                next_state = s4;
                next_moving_state = STOP;
              end
              else begin
                next_state = s3;
                if (moving_state == TURN_LEFT) next_moving_state = TURN_LEFT;
                else next_moving_state = TURN_RIGHT;
              end
            end
            1'b0: begin
              if (turn_cnt >= 16'd100) begin
                next_state = s4;
                next_moving_state = STOP;
              end
              else begin
                next_state = s3;
                if (moving_state == TURN_LEFT) next_moving_state = TURN_LEFT;
                else next_moving_state = TURN_RIGHT;
              end
            end
            default: begin
              next_state = s3;
              if (moving_state == TURN_LEFT) next_moving_state = TURN_LEFT;
              else next_moving_state = TURN_RIGHT;
            end
          endcase
      end
        s4:begin
          if (cool_cnt >= 11'd50) begin
            next_state = s1;
            next_moving_state = MOVE_FORWARD;
          end
          else begin
            next_state = s4;
            next_moving_state = MOVE_FORWARD;
          end
        end
      endcase
    end
    else begin
      next_state = s2;
      next_moving_state = STOP;
    end
  end


endmodule