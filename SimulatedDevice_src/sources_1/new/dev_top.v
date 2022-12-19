`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2022/10/26 22:10:40
// Design Name: 
// Module Name: dev_top
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module SimulatedDevice(
    input[1:0] global_state,
    input sys_clk, //bind to P17 pin (100MHz system clock)
    input rx, //bind to N5 pin
    output tx, //bind to T4 pin
    input turn_left_signal,
    input turn_right_signal,
    input move_forward_signal,
    input move_backward_signal,
    input place_barrier_signal,
    input destroy_barrier_signal,
    input rst,
    input clutch,
    input throttle,
    input brake,
    input power_on,
    input power_off,
    output front_detector,
    output back_detector,
    output left_detector,
    output right_detector,
    output turn_left_light,
    output turn_right_light,
    output power_light,
    output reg [2:0] state_light,
    output reg [3:0] moving_light
    );
    reg power;
    reg [1:0] state = 2'b00;
    reg [3:0] moving_state = 4'b0000;
    wire manual_power;
    wire [1:0] next_state1;
    wire [1:0] next_state2;
    wire [3:0] next_moving_state1;
    wire [3:0] next_moving_state2;
    wire next_power;

    engine en(.global_state(global_state), .clk(sys_clk), .rst(rst), .power_on(power_on), .power_off(power_off), 
    .manual_power(manual_power), .next_power(next_power), .power_light(power_light));

    manual ma(.power(power), .global_state(global_state), .state(state), .moving_state(moving_state), .clutch(clutch), 
    .brake(brake), .throttle(throttle), .rgs(move_backward_signal), .left(turn_left_signal), 
    .right(turn_right_signal), .next_state(next_state1), .next_moving_state(next_moving_state1),
    .manual_power(manual_power), .turn_left_light(turn_left_light), .turn_right_light(turn_right_light));

    semi_auto sa(.power(power), .global_state(global_state),
    .detector({front_detector, left_detector, right_detector, back_detector}),
    .state(state), .rst(rst), .sys_clk(sys_clk), .turn_left(turn_left_signal), .turn_right(turn_right_signal), 
    .go_straight(move_forward_signal), .go_back(move_backward_signal), .next_state(next_state2),
    .next_moving_state(next_moving_state2));

    always @(next_power) begin
        power = next_power;
    end

    always @(*) begin
      if (power == 1'b1) begin
        if (state == 2'b00) state_light = 3'b001;
        else if (state == 2'b01) state_light = 3'b010;
        else state_light = 3'b100;
        moving_light = moving_state;
      end 
      else begin
        state_light = 3'b000;
        moving_light = 4'b0000;
      end
    end

    always @(*) begin
        case (global_state)
            2'b00:begin
                state = next_state1;
                moving_state = next_moving_state1;
            end 
            2'b01:begin
                state = next_state2;
                moving_state = next_moving_state2;
            end
            2'b10:begin
                state = next_state2;
                moving_state = next_moving_state2;
            end
            2'b11:begin
                
            end
        endcase
    end

    wire [7:0] in = {2'b10, destroy_barrier_signal, place_barrier_signal, moving_state};
    wire [7:0] rec;
    assign front_detector = rec[0];
    assign left_detector = rec[1];
    assign right_detector = rec[2];
    assign back_detector = rec[3];
    
    uart_top md(.clk(sys_clk), .rst(0), .data_in(in), .data_rec(rec), .rxd(rx), .txd(tx));
    
endmodule
