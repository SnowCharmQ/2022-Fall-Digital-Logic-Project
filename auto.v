`timescale 1ns / 1ps

module auto(input sys_clk, rst, power,
global_state, input[1:0] state, input[3:0] moving_state, input[3:0] detector,
output reg pl_beacon_sig, output reg de_beacon_sig,
output reg[1:0] next_state, output reg[3:0] next_moving_state);

    parameter MOVING=2'b01, WAITING=2'b00, TURNING=2'b10, COOLING=2'b11;
    parameter MOVE_FORWARD=4'b0001, STOP=4'b0000, TURN_LEFT=4'b0100, TURN_RIGHT=4'b1000;

    reg crossroad = 1'b1;
    reg [3:0] nms = 4'b0000;
    reg [10:0] turn_cnt;
    reg [10:0] cool_cnt;
    reg [10:0] wait_cnt;
    wire clk_ms,clk_20ms,clk_16x,clk_x;
    divclk myclk(sys_clk,clk_ms,clk_20ms,clk_16x,clk_x);

    always @(*) begin
        if (power == 1'b1 && global_state == 2'b01) begin
            case (state)
                MOVING: begin
                  case (crossroad)
                    1'b0: begin
                      next_state = MOVING;
                      next_moving_state = MOVE_FORWARD;
                    end
                    1'b1: begin
                      next_state = WAITING;
                      next_moving_state = STOP;
                    end
                  endcase
                end
                WAITING: begin
                  if (wait_cnt >= 11'd100) begin
                    case (nms)
                        MOVE_FORWARD: begin
                            next_state = COOLING;
                            next_moving_state = MOVE_FORWARD;
                        end
                        TURN_LEFT: begin
                            next_state = TURNING;
                            next_moving_state = TURN_LEFT;
                        end
                        TURN_RIGHT: begin
                            next_state = TURNING;
                            next_moving_state = TURN_RIGHT;
                        end
                        STOP: begin
                            next_state = WAITING;
                            next_moving_state = STOP;
                        end
                    endcase
                  end
                  else begin
                    next_state = WAITING;
                    next_moving_state = STOP;
                  end       
                end 
                TURNING: begin
                    if (turn_cnt >= 11'd100) begin
                        next_state = COOLING;
                        next_moving_state = MOVE_FORWARD;
                    end
                    else begin
                        next_state = TURNING;
                        if (moving_state == TURN_LEFT) next_moving_state = TURN_LEFT;
                        else next_moving_state = TURN_RIGHT;
                    end
                end
                COOLING: begin
                    if (cool_cnt >= 11'd50) begin
                        next_state = MOVING;
                        next_moving_state = MOVE_FORWARD;
                    end
                    else begin
                        next_state = COOLING;
                        next_moving_state = MOVE_FORWARD;
                    end
                end
            endcase
        end
        else begin
          next_state = WAITING;
          next_moving_state = STOP;
        end
    end

    always @(posedge sys_clk) begin
         case (detector) //{front_detector, left_detector, right_detector, back_detector}
            4'b0001: nms <= TURN_LEFT;
            4'b0010: nms <= TURN_LEFT;
            4'b0011: nms <= TURN_LEFT;
            4'b1010: nms <= TURN_LEFT;
            4'b1011: nms <= TURN_LEFT;
            4'b0000: nms <= TURN_RIGHT;
            4'b0100: nms <= TURN_RIGHT;
            4'b0101: nms <= TURN_RIGHT;
            4'b1000: nms <= TURN_RIGHT;
            4'b1001: nms <= TURN_RIGHT;
            4'b1100: nms <= TURN_RIGHT;
            4'b1101: nms <= TURN_RIGHT;
            4'b0110: nms <= MOVE_FORWARD;
            4'b0111: nms <= MOVE_FORWARD;
            4'b1110: nms <= MOVE_FORWARD;
            4'b1111: nms <= MOVE_FORWARD;
         endcase
    end

    always @(posedge sys_clk) begin
        if (detector[0] || ~detector[1] || ~detector[2]) crossroad <= 1'b1;
        else crossroad <= 1'b0;
    end

    always @(posedge clk_20ms) begin
        if (rst == 1'b1) begin
            wait_cnt <= 11'b0;
        end
        else begin
            if (state == WAITING) wait_cnt <= wait_cnt + 11'b1;
            else wait_cnt <= 11'b0;
        end
    end

    always @(posedge clk_20ms) begin
        if (rst == 1'b1) begin
            turn_cnt <= 11'b0;
        end
        else begin
            if (state == TURNING) turn_cnt <= turn_cnt + 11'b1;
            else turn_cnt <= 11'b0;
        end
    end

    always @(posedge clk_20ms) begin
        if (rst == 1'b1) begin
            cool_cnt <= 11'b0;
        end
        else begin
            if (state == COOLING) cool_cnt <= cool_cnt + 11'b1;
            else cool_cnt <= 11'b0;
        end
    end

endmodule