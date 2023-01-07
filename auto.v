`timescale 1ns / 1ps

module auto(input sys_clk, rst, power,
global_state, input[3:0] turn_detector,
output reg pl_beacon_sig, output reg de_beacon_sig,
output reg[1:0] next_state,output reg[3:0] next_moving_state);

    reg[7:0] turn_time_cnt = 8'b0;
    reg[7:0] move_time_cnt = 8'b0;
    reg[7:0] wait_time_cnt = 8'b0;
    reg pl_beacon = 1'b0, de_beacon = 1'b0;
    reg[3:0] turn; 
    reg[1:0] state;
    //reg btobe_pl;//reg if_fork;//valid: turn until 90 degrees
    parameter front=4'b0001,back=4'b0010,left=4'b0100,right=4'b1000;
    parameter PON=1'b1,POFF=1'b0;//no need,if no power no electricity.
    parameter MOVE=2'b10,TURN=2'b01,WAIT=2'b00;
    parameter turn_period=8'd100,move_period=8'd50,wait_period=8'd10;

    wire clk_ms,clk_20ms,clk_16x,clk_x;
    divclk myclk(sys_clk,clk_ms,clk_20ms,clk_16x,clk_x);
  
    always@(sys_clk) begin
      if (power == PON && global_state == 2'b11) begin
        if (state == MOVE) begin
          de_beacon <= 1'b0;
          pl_beacon <= 1'b0;
          state <= TURN;//turn=front;
          case (turn_detector)
            ~left: turn <= left;//left is okay,others' stucked
            ~right: turn <= right;
            ~back: begin 
              de_beacon <= 1'b1;
              state <= WAIT;
            end
            4'b0000: begin 
              turn <= right;
              pl_beacon <= 1'b1;
            end //lrbf okay
            left: begin 
              turn <= right;
              pl_beacon <= 1'b1;
            end
            right: begin 
              turn <= front;
              pl_beacon <= 1'b1;
            end
            front: begin 
              turn <= right;
              pl_beacon <= 1'b1;
            end
            back: begin 
              turn <= right;
              pl_beacon <= 1'b1;
            end
            //two dirctions bfrl(okay:1'b0) 6coniditions
            //bf
            4'b0101: turn <= left;//bl
            4'b1001: turn <= right;//br
            4'b0011: turn <= right;//rl
            4'b1010: turn <= right;//fr
            4'b0110: turn <= front;//fl
            default: turn <= front;
          endcase
        end
        else if (state == WAIT) begin
          state <= MOVE;
          turn <= front;
        end
      end
    end
    
    always@(*) begin
      if (power == PON && global_state == 2'b11) begin
        case(state) 
          TURN: begin
            if(turn_time_cnt == turn_period) begin
              state = MOVE;
            end
            else begin
              state = TURN;
            end
          end
          MOVE: begin
            if(move_time_cnt == move_period) begin
              state = WAIT;
            end
            else begin
              state = MOVE;
            end
          end
          WAIT: begin
            if(wait_time_cnt == wait_period) begin
              state = MOVE;
            end
            else begin 
              state = WAIT;
            end
          end
        endcase
      end
    end
    
    always@(posedge clk_20ms) begin
      if (power == PON && global_state == 2'b11) begin
        next_moving_state <= turn;
        next_state <= state;
        de_beacon_sig <= de_beacon;
        if(state == TURN) begin
          move_time_cnt <= 8'b0;
          wait_time_cnt <= 8'b0;
          turn_time_cnt <= turn_time_cnt + 5'd20;
        end 
        else if(state == MOVE) begin
          wait_time_cnt <= 8'b0;
          turn_time_cnt <= 8'b0;
          if(pl_beacon) begin
            if (move_time_cnt == move_period) begin 
              pl_beacon_sig <= pl_beacon; 
            end
            else begin
              move_time_cnt <= move_time_cnt + 5'd20;
            end 
          end
        end
        else if (state == WAIT) begin
          move_time_cnt <= 8'b0;
          turn_time_cnt <= 8'b0;
          wait_time_cnt <= wait_time_cnt + 5'd20;
        end 
      end
    end
     
endmodule