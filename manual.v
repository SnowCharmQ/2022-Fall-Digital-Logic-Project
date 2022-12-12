`timescale 1ns / 1ps

module manual(input clk, rst, power_on, power_off, power, input[1:0] state, input[3:0] moving_state, input clutch,brake,throttle,rgs,left,right,
output reg [1:0] next_state, output reg next_power, output reg [3:0] next_moving_state, output reg turn_left_light, output reg turn_right_light
    );
    parameter POFF=1'b0,PON=1'b1;//电源启动状态
    parameter NSTART=2'b00,START=2'b01,MOVING=2'b10;//小车运行状态
    parameter NON_MOVING=4'b0000,MOVE_FORWARD=4'b0001,MOVE_BACK=4'b0010,
    TURN_LEFT=4'b0100,TURN_RIGHT=4'b1000;//小车行驶状态

    wire clk_ms,clk_20ms,clk_16x,clk_x;
    divclk my_divclk(
        .clk(clk),
        .clk_ms(clk_ms),
        .btnclk(clk_20ms),
        .clk_16x(clk_16x),
        .clk_x(clk_x)
    );
    reg power1, power2;
    reg [9:0] cnt;
    initial begin
      cnt = 10'b0;
      power1 = 1'b0;
      power2 = 1'b0;
    end 

    always @(posedge clk_ms or negedge rst) begin
        if (rst) begin
          cnt <= 10'b0;
          power1 <= 1'b0;
        end
        else begin
          if (power_on == 1'b1 && power1 == 1'b0) begin
            cnt <= cnt + 10'b1;
            if (cnt == 10'd1000) begin
                cnt <= 10'b0;
                power1 <= 1'b1;
            end
          end
          if (power1 == 1'b1 && power_off == 1'b1) begin
            cnt <= 10'b0;
            power1 <= 1'b0;
          end
          if (power_on != 1'b1 && power2 == POFF) begin
            cnt <= 10'b0;
            power1 <= 1'b0;
          end
        end
    end

    always @(power,clutch,brake,throttle,rgs,left,right,state,moving_state) begin
    if (power == PON) begin
      case(state)

      NSTART:begin
      turn_left_light = 1'b1;
      turn_right_light = 1'b1;
      if(throttle&&~clutch) begin next_state=NSTART;power2=POFF; end
      else if(throttle&&clutch&&~brake&&~rgs) begin next_state=START;power2=PON; end
      else if (brake) begin next_state=NSTART;power2=PON; end
      else begin next_state=state;power2=power; end
      next_moving_state = NON_MOVING;
      end
      
      START:begin
      turn_left_light = 1'b0;
      turn_right_light = 1'b0;
      power2 = PON;
      if(~clutch&&~brake&&throttle) begin next_state=MOVING;next_moving_state=MOVE_FORWARD; end
      else if (brake) begin next_state=NSTART;next_moving_state=NON_MOVING; end
      else begin next_state=state;power2=power; end
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
        power2 = POFF;
        next_state = NSTART;
        next_moving_state = NON_MOVING;
      end
      else if (~throttle&&clutch) begin
        power2 = PON;
        next_state = START;
        next_moving_state = NON_MOVING;
      end
      else if (brake) begin
        power2 = PON;
        next_state = NSTART;
        next_moving_state = NON_MOVING;
      end
      else if (rgs&&clutch) begin
        power2 = PON;
        next_state = state;
        next_moving_state = MOVE_BACK;
      end
      else begin
        power2 = PON;
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
    end
    end
           
    always @(power1, power2) begin
      next_power = power1;
    end
    
endmodule

