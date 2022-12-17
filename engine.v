`timescale 1ns / 1ps

module engine(input clk, rst, power_on, power_off, manual_power, output reg next_power);
    parameter POFF=1'b0,PON=1'b1;

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
          if (power_on != 1'b1 && manual_power == POFF) begin
            cnt <= 10'b0;
            power1 <= 1'b0;
          end
        end
    end

    always @(power1) begin
        next_power = power1;
    end


endmodule