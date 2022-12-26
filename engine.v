`timescale 1ns / 1ps

module engine(input [1:0] global_state, input clk, rst, power_on, power_off, manual_power, 
              output reg next_power, output reg power_light);
    parameter POFF=1'b0,PON=1'b1;
    reg [1:0] temp_state;

    wire clk_ms,clk_20ms,clk_16x,clk_x;
    divclk my_divclk(
        .clk(clk),
        .clk_ms(clk_ms),
        .btnclk(clk_20ms),
        .clk_16x(clk_16x),
        .clk_x(clk_x)
    );

    reg power1;
    reg [9:0] cnt;
    always @(posedge clk_ms) begin
        if (rst == 1'b1) begin
          temp_state = 2'b00;
        end
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
          if (global_state == 2'b00 && power_on != 1'b1 && manual_power == POFF) begin
            cnt <= 10'b0;
            power1 <= 1'b0;
          end
          if (temp_state != global_state) begin
            temp_state = global_state;
            cnt <= 10'b0;
            power1 <= 1'b0;
          end
        end
    end

    always @(power1, global_state) begin
        next_power = power1;
        power_light = next_power;
    end

endmodule