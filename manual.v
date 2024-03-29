`timescale 1ns / 1ps

module manual(input clk, input rst, input power, input[1:0] global_state, input[1:0] state, 
input[3:0] moving_state, input clutch,brake,throttle,rgs,left,right,
output reg [1:0] next_state, output reg [3:0] next_moving_state, 
output reg manual_power, output reg turn_left_light, output reg turn_right_light,
output [7:0] seg1, output [7:0] seg2, output [7:0] an);
    parameter POFF=1'b0,PON=1'b1;//电源启动状态
    parameter NSTART=2'b00,START=2'b01,MOVING=2'b10;//小车运行状态
    parameter NON_MOVING=4'b0000,MOVE_FORWARD=4'b0001,MOVE_BACK=4'b0010,
    TURN_RIGHT=4'b1000,TURN_LEFT=4'b0100;//小车行驶状态
    reg activate;
    reg moving;

    milecounter mc(.clk(clk), .rst(rst), .moving(moving), .activate(activate),
    .seg1(seg1), .seg2(seg2), .an(an));

    always @(power, global_state) begin
      if (power == 1'b1 && global_state == 2'b00) activate = 1'b1;
      else activate = 1'b0;
    end

    always @(moving_state) begin
      if (moving_state == MOVE_FORWARD || moving_state == MOVE_BACK) moving = 1'b1;
      else moving = 1'b0;
    end
    
    always @(global_state,power,clutch,brake,throttle,rgs,left,right,state,moving_state) begin
    if (power == PON && global_state == 2'b00) begin
      case(state)

      NSTART:begin
        turn_left_light = 1'b1;
        turn_right_light = 1'b1;
      if (brake) begin 
        next_state = NSTART;
        manual_power = PON; 
      end
      else if(throttle&&~clutch) begin 
        next_state = NSTART;
        manual_power = POFF; 
      end
      else if(throttle&&clutch&&~brake&&~rgs) begin 
        next_state = START;
        manual_power = PON; 
      end
      else begin 
        next_state = state;
        manual_power = power; 
      end
      next_moving_state = NON_MOVING;
      end
      
      START:begin
      turn_left_light = 1'b0;
      turn_right_light = 1'b0;
      manual_power = PON;
      if (brake) begin 
        next_state = NSTART;
        next_moving_state = NON_MOVING; 
      end
      else if (~clutch&&throttle) begin 
        next_state = MOVING;
        if (rgs) next_moving_state = MOVE_BACK;
        else next_moving_state = MOVE_FORWARD; 
      end
      else if (~throttle) begin
        next_state = state;
        next_moving_state = NON_MOVING;
        manual_power = power;
      end
      else begin 
        next_state = state;
        next_moving_state = moving_state;
        manual_power = power; 
      end
      if (next_state != NSTART && next_moving_state != NON_MOVING && next_moving_state != MOVE_BACK) begin
        if(~left&&~right) begin 
          if (next_state == MOVING) next_moving_state = MOVE_FORWARD;
          turn_left_light = 1'b0;
          turn_right_light = 1'b0;
        end 
        else if (~left&&right) begin
          if (next_state == MOVING) next_moving_state = TURN_RIGHT;
          turn_left_light = 1'b0;
          turn_right_light = 1'b1;
        end
        else if (left&&~right) begin
          if (next_state == MOVING) next_moving_state = TURN_LEFT;
          turn_right_light = 1'b0;
          turn_left_light = 1'b1;
        end
        else begin
          if (next_state == MOVING) next_moving_state = MOVE_FORWARD;
          turn_left_light = 1'b1;
          turn_right_light = 1'b1;
        end
      end
      end

      MOVING:begin
      if (rgs&&~clutch) begin
        manual_power = POFF;
        next_state = NSTART;
        next_moving_state = NON_MOVING;
      end
      else if (brake) begin
        manual_power = PON;
        next_state = NSTART;
        next_moving_state = NON_MOVING;
      end
      else if (~throttle) begin
        manual_power = PON;
        next_state = START;
        next_moving_state = NON_MOVING;
      end
      else if (rgs&&clutch) begin
        manual_power = PON;
        next_state = MOVING;
        next_moving_state = MOVE_BACK;
      end
      else if (~rgs) begin
        manual_power = PON;
        next_state = MOVING;
        next_moving_state = MOVE_FORWARD;
      end
      else begin
        manual_power = PON;
        next_state = state;
        next_moving_state = moving_state;
      end
      if (next_state != NSTART && next_moving_state != NON_MOVING && next_moving_state != MOVE_BACK) begin
        if(~left&&~right) begin 
          if (next_state == MOVING) next_moving_state = MOVE_FORWARD;
          turn_left_light = 1'b0;
          turn_right_light = 1'b0;
        end 
        else if (~left&&right) begin
          if (next_state == MOVING) next_moving_state = TURN_RIGHT;
          turn_left_light = 1'b0;
          turn_right_light = 1'b1;
        end
        else if (left&&~right) begin
          if (next_state == MOVING) next_moving_state = TURN_LEFT;
          turn_right_light = 1'b0;
          turn_left_light = 1'b1;
        end
        else begin
          if (next_state == MOVING) next_moving_state = MOVE_FORWARD;
          turn_left_light = 1'b1;
          turn_right_light = 1'b1;
        end
      end
      end
      endcase
    end
    else begin
      turn_left_light = 1'b0;
      turn_right_light = 1'b0; 
      next_state = NSTART;
      next_moving_state = NON_MOVING;
    end
    end
    
endmodule
