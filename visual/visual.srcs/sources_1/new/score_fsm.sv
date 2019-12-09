`timescale 1ns / 1ps

module score_fsm(input clk, 
                 input start, 
                 input rst_in, 
                 input game_over, 
                 input score_ready, 
                 input correct,
                 input perfect,
                 
                 output logic streak_out, 
                 output[31:0] updated_score
    );

    // states for different increments  
    parameter IDLE = 0;
    parameter IS_STREAK = 1;
    parameter STREAK_INCR = 2;
    parameter NORM_INCR = 3;
    
    reg [4:0] state = 0;
    
    // initialize the score 
    reg[31:0] score = 0;
    reg[9:0] streak = 0;
    logic[4:0] prev_correct = 0;
    assign updated_score = score;
    
    assign streak_out = (streak > 0);
    
    
    always_ff @(posedge clk) begin 
        if (rst_in) begin 
            score <= 0; // system reset score to 0
            state <= IDLE;
        end      
        case(state)
            IDLE: begin 
                score <= 0;
                streak<= 0;
                prev_correct<=0;
                if (start) state <= IS_STREAK;
            end
            IS_STREAK: begin
                if (score_ready) begin
                    prev_correct <= {prev_correct[3:0],correct};
                    if (prev_correct==5'b11111) state<= STREAK_INCR;
                    else state<= NORM_INCR;
                end
            end   
            STREAK_INCR: begin 
                if (correct&&perfect) begin 
                    score <= score + 4;
                    streak <= streak + 1;
                end else if (correct && (!perfect)) begin 
                    score <= score + 2;
                    streak <= streak + 1;
                end else streak<=0;
                state<=IS_STREAK;
            end     
            NORM_INCR: begin 
                streak<= 0;
                
                if (correct&&perfect) begin 
                    score <= score + 2;
                end else if (correct && (!perfect)) begin 
                    score <= score + 1;
                end 
                
                state<=IS_STREAK;
            end
        endcase
    end 
endmodule
