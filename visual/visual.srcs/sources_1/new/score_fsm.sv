`timescale 1ns / 1ps

module score_fsm(input clk, 
                 input start, 
                 input rst_in, 
                 input game_over, 
                 input score_ready, 
                 input correct,
                 
                 output[31:0] updated_score
    );

    // states for different increments  
    parameter IDLE = 0;
    parameter INCREMENT = 1;
    reg [1:0] state = 0; 
    
    
    // initialize the score 
    reg [31:0] score = 0;
    assign updated_score = score;
    
    always_ff @(posedge clk) begin 
        if (rst_in) begin 
            score <= 0; // system reset score to 0
            state <= IDLE;
        end      
        case(state)
            IDLE: begin 
                if (start) begin 
                    score <= 0;
                    state <= INCREMENT;
                end 
            end
            INCREMENT: begin
                if (score_ready && correct) score<= (score + 1'b1);
//                if (game_over) state <= IDLE;
//                else begin
//                    score <= (score + (score_ready && correct));  // increment score by 1
//                end 
                
            end   
        endcase
    end 
endmodule
