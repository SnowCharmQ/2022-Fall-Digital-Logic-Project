`timescale 1ns / 1ps

module auto(input sys_clk, rst, power,
global_state, state, moving_state, input[3:0] detectors,
output reg pl_beacon_sig, output reg de_beacon_sig,
output reg[1:0] next_state,output reg[3:0] next_moving_state);

    parameter MOVING=2'b01, WAITING=2'b00, TURING=2'b10, COOLING=2'b11;
    parameter MOVE_FORWARD=4'b0001, STOP=4'b0000, TURN_LEFT=4'b0100, TURN_RIGHT=4'b1000;
    parameter front=4'b0001,back=4'b0010,right=4'b0100,left=4'b1000;

    reg change = 1'b1;
    reg [15:0] turn_cnt;
    reg [10:0] cool_cnt;
    reg [3:0] nms;
    reg[3:0] tmp_detector = 4'b0000;
    wire clk_ms,clk_20ms,clk_16x,clk_x;
    divclk myclk(sys_clk,clk_ms,clk_20ms,clk_16x,clk_x);

    always @(*) begin
        if (power == 1'b1 && global_state == 2'b01) begin
            next_state = MOVING;
            next_moving_state = MOVE_FORWARD;
        end
        else begin
          next_state = WAITING;
          next_moving_state = STOP;
        end
    end

    // always @(posedge sys_clk) begin
    //     if (tmp_detector != detectors) begin
    //       change = 1'b1;
    //       tmp_detector <= detectors;
    //     end
    //     else begin
    //       change = 1'b0;
    //     end
    // end

    // always @(posedge clk_20ms) begin
    //     if (rst == 1'b1) begin
    //         turn_cnt <= 11'b0;
    //     end
    //     else begin
    //         if (state == TURING) turn_cnt <= turn_cnt + 11'b1;
    //         else turn_cnt <= 11'b0;
    //     end
    // end

    // always @(posedge clk_20ms) begin
    //     if (rst == 1'b1) begin
    //         cool_cnt <= 11'b0;
    //     end
    //     else begin
    //         if (state == COOLING) cool_cnt <= cool_cnt + 11'b1;
    //         else cool_cnt <= 11'b0;
    //     end
    // end

    // always @(posedge sys_clk) begin
    //   case (detectors)
    //     ~left: nms <= left;//left is okay,others' stucked
    //     ~right: nms <= right;
    //     4'b0000: begin 
    //       nms <= right;
    //     end //lrbf okay
    //     left: begin 
    //       nms <= right;
    //     end
    //     right: begin 
    //       nms <= front;
    //     end
    //     front: begin 
    //       nms <= right;
    //     end
    //     back: begin 
    //       nms <= right;
    //     end
    //     4'b0101: nms <= left;//bl
    //     4'b1001: nms <= right;//br
    //     4'b0011: nms <= right;//rl
    //     4'b1010: nms <= right;//fr
    //     4'b0110: nms <= front;//fl
    //     default: nms <= front;
    //   endcase
    // end

endmodule