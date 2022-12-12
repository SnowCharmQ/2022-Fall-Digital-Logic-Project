`timescale 1ns / 1ps

module manual(input clk, rst, input power, input[1:0] state, input[3:0] moving_state, input clutch,brake,throttle,rgs,left,right,
output reg [1:0] next_state, output reg next_power, output reg [3:0] next_moving_state, output reg turn_left_light, output reg turn_right_light
    );
    parameter POFF=1'b0,PON=1'b1;//电源启动状态
    parameter NSTART=2'b00,START=2'b01,MOVING=2'b10;//小车运行状态
    parameter NON_MOVING=4'b0000,MOVE_FORWARD=4'b0001,MOVE_BACK=4'b0010,TURN_LEFT=4'b0100,TURN_RIGHT=4'b1000;//小车行驶状态
    always@(*) begin
    if(power == PON) begin
      case(state)

      NSTART:begin
      turn_left_light = 1'b1;
      turn_right_light = 1'b1;
      if(throttle&&~clutch) begin next_state=NSTART;next_power=POFF; end
      else if(throttle&&clutch&&~brake&&~rgs) begin next_state=START;next_power=PON; end
      else if (brake) begin next_state=NSTART;next_power=PON; end
      else begin next_state=state;next_power=power; end
      next_moving_state = NON_MOVING;
      end
      
      START:begin
      turn_left_light = 1'b0;
      turn_right_light = 1'b0;
      next_power = PON;
      if(~clutch&&~brake&&throttle) begin next_state=MOVING;next_moving_state=MOVE_FORWARD; end
      else if (brake) begin next_state=NSTART;next_moving_state=NON_MOVING; end
      else begin next_state=state;next_power=power; end
      if (next_state != NSTART) begin
        if(left&&~right) begin 
          if (next_state == MOVING) next_moving_state = TURN_LEFT;
          turn_left_light = 1'b1;
          turn_right_light = 1'b0;
        end 
        else if (~left&&right) begin
          if (next_state == MOVING) next_moving_state = TURN_RIGHT;
          turn_right_light = 1'b1;
          turn_left_light = 1'b0;
        end
        else if (left&&right) begin
          if (next_state == MOVING) next_moving_state = MOVE_FORWARD;
          turn_right_light = 1'b1;
          turn_left_light = 1'b1;
        end
        else begin
          if (next_state == MOVING) next_moving_state = MOVE_FORWARD;
          turn_right_light = 1'b0;
          turn_left_light = 1'b0;
        end
      end
      end
      
      MOVING:begin
      if (rgs&&~clutch) begin
        next_power = POFF;
        next_state = NSTART;
        next_moving_state = NON_MOVING;
      end
      else if (~throttle&&clutch) begin
        next_power = PON;
        next_state = START;
        next_moving_state = NON_MOVING;
      end
      else if (brake) begin
        next_power = PON;
        next_state = NSTART;
        next_moving_state = NON_MOVING;
      end
      else if (rgs&&clutch) begin
        next_power = PON;
        next_state = state;
        next_moving_state = MOVE_BACK;
      end
      else begin
        next_power = PON;
        next_state = state;
        next_moving_state = moving_state;
      end
      end
      endcase
    end
    else begin
      turn_left_light = 1'b0;
      turn_right_light = 1'b0; 
      next_state = NSTART;
      next_moving_state = NON_MOVING;
      next_power = POFF;
    end
    if (next_power == POFF) begin
      turn_left_light = 1'b0;
      turn_right_light = 1'b0; 
      next_state = NSTART;
      next_moving_state = NON_MOVING;
      next_power = POFF;
    end
    end
           
    
endmodule

