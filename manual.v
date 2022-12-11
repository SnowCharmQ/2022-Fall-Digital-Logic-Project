`timescale 1ns / 1ps

module manual(input clk, rst, input power, input[1:0] state, input clutch,brake,throttle,rgs,turn_left,turn_right,
output reg [1:0] next_state, output reg next_power, output reg turn_left_light, output reg turn_right_light
    );
    parameter POFF=1'b0,PON=1'b1;//no 1'b? 64/32?
    parameter NSTART=2'b00,START=2'b01,MOVING=2'b10;
    parameter MOVE_STRAIGHT=3'b000,MOVE_BACK=3'b001,MOVE_FORWARD=3'b010,TURN_LEFT=3'b011,TURN_RIGHT=3'b100;
    always@* begin
    if(power == PON) begin
      case(state)
      NSTART:begin
      turn_left_light = 1'b1;
      turn_right_light = 1'b1;
      // if(throttle&&~clutch) next_power=0;
      // else if(throttle&&~brake&&clutch) next_state=start;
      // else begin next_state=state;next_power=power;end
      end
      
      START:begin
      // if(~clutch&&~brake&&throttle) next_state=move;
      // else if(brake) next_state=nstart;
      // else begin next_state=state;next_power=power;end
      // if(turn_left&&~turn_right) next_state=turn_l;
      // else if(~turn_left&&turn_right) next_state=turn_r;
      // else next_state=move_straight;
      end
      
      MOVING:begin
      // if(rgs&&~clutch) begin next_power=0;next_state=nstart;end
      // else if(~throttle&&clutch) next_state=start;
      // else if(brake) next_state=nstart;
      // else begin next_state=state;next_power=power;end
      // if(rgs&&clutch) next_state=move_back;
      // else if(~rgs&&clutch) next_state=move_forward;
      end

      endcase
    end
    else begin
      turn_left_light = 1'b0;
      turn_right_light = 1'b0; 
    end
    end
           
    
endmodule

