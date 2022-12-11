`timescale 1ns / 1ps

module engine(input clk, rst, power_on, power_off, output reg power);

wire clk_ms,clk_20ms,clk_16x,clk_x;
divclk my_divclk(
    .clk(clk),
    .clk_ms(clk_ms),
    .btnclk(clk_20ms),
    .clk_16x(clk_16x),
    .clk_x(clk_x)
);

reg [9:0] cnt;
initial cnt = 10'b0;

always @(posedge clk_ms or negedge rst) begin
    if (rst) begin
      cnt <= 10'b0;
      power <= 1'b0;
    end
    else begin
      if (power_on == 1'b1 && power == 1'b0) begin
        cnt <= cnt + 10'b1;
        if (cnt == 10'd1000) begin
            cnt <= 10'b0;
            power <= 1'b1;
        end
      end
      if (power_on == 1'b0) begin
        cnt <= 10'b0;
      end   
      if (power == 1'b1 && power_off == 1'b1) begin
        cnt <= 10'b0;
        power <= 1'b0;
      end
    end
end

endmodule