`timescale 1ns / 1ps

//////////////////////////////////////////////////////////////////////////////////
//
// score_fsm: update score based on correct, perfect, streak 
//
//////////////////////////////////////////////////////////////////////////////////

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
    
    // updated score
    assign updated_score = score;
    
    // previous 5 moves have all been correct
    logic[4:0] correct_5 = 5'b11111;
    
    // streak signal
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
            // checks if one is in a streak
            IS_STREAK: begin
                if (score_ready) begin
                    prev_correct <= {prev_correct[3:0],correct}; // the previous 5 steps 
                    // based on streak state increment accordingly
                    if (prev_correct==correct_5) state<= STREAK_INCR; 
                    else state<= NORM_INCR;
                end
            end   
            // if in streak increment according to correct and if perfect 
            STREAK_INCR: begin 
                if (correct) begin 
                    if (perfect) begin 
                        score <= score + 4;
                        streak <= streak + 1;
                    end else begin 
                        score <= score + 2;
                        streak <= streak + 1;
                    end
                end else streak<=0; // if not correct => loose streak
                state<=IS_STREAK;
            end     
            // if not in streak increment according to correct and if perfect 
            NORM_INCR: begin 
                streak<= 0;
                if (correct) begin 
                    if (perfect) begin 
                        score <= score + 2;
                    end else begin 
                        score <= score + 1;
                    end
                end 
                state<=IS_STREAK;
            end
        endcase
    end 
endmodule
