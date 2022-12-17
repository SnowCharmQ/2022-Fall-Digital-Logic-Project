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
    output [2:0] state_light,
    output [3:0] moving_light
    );
    reg power;
    reg [1:0] state;
    reg [3:0] moving_state;
    wire manual_power;
    wire [1:0] next_state;
    wire [3:0] next_moving_state;
    wire next_power;

    initial begin
    power = 1'b0;
    state = 2'b00;
    moving_state = 4'b0000;
    end

    engine en(.clk(sys_clk), .rst(rst), .power_on(power_on), .power_off(power_off), 
    .manual_power(manual_power), .next_power(next_power));

    manual ma(.power(power), .state(state), .moving_state(moving_state), .clutch(clutch), 
    .brake(brake), .throttle(throttle), .rgs(move_backward_signal), .left(turn_left_signal), 
    .right(turn_right_signal), .next_state(next_state), .next_moving_state(next_moving_state),
    .manual_power(manual_power), .turn_left_light(turn_left_light), .turn_right_light(turn_right_light), 
    .power_light(power_light), .state_light(state_light), .moving_light(moving_light));

    always @(*) begin
        power = next_power;
        state = next_state;
        moving_state = next_moving_state;
    end

    wire [7:0] in = {2'b10, destroy_barrier_signal, place_barrier_signal, moving_state};
    wire [7:0] rec;
    assign front_detector = rec[0];
    assign left_detector = rec[1];
    assign right_detector = rec[2];
    assign back_detector = rec[3];
    
    uart_top md(.clk(sys_clk), .rst(0), .data_in(in), .data_rec(rec), .rxd(rx), .txd(tx));
    
endmodule
