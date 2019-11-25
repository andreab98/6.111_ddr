`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 11/17/2019 05:04:51 PM
// Design Name: 
// Module Name: score_fsm
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


module score_fsm(input clk, 
                 input start, 
                 input rst_in, 
                 input game_over, 
                 input score_ready, 
                 input correct,
                 
                 output logic [31:0] updated_score
    );
  
    
    // states for different increments  
    parameter IDLE = 2'b01;
    parameter INCREMENT = 2'b10;
    logic [1:0] state = IDLE; 
    
    
    // initialize the score 
    logic [31:0] score = 0;
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
                if (game_over) begin 
                    state <= IDLE;
                end 
                
                else begin
                score <= score + (score_ready && correct);  // increment score by 1
                end 
                
            end   
        endcase
    end 
endmodule
