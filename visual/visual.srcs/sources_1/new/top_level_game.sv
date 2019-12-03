`timescale 1ns / 1ps

module top_level_game(input clk, // system clock
                      input reset, // system reset
                      input start, // games start (might not need this)
                      
                      input [8:0] sensor_data,
                      input [8:0] correct_data,
                      input ready_in,
                      
                      output logic correct,
                      
                      output logic [31:0] score
                       
    );
    
    //Comparison Module Inputs
//    logic [8:0] correct_data; // data stored in memory (COMES FROM VISUAL MODULE)
//    logic [8:0] intersection_data; // data from sensors -- player's actions (COMES FROM SENSOR MODULE)
//    logic ready_in; // HIGH when arrow passes threshold on screen (COMES FROM VISUAL MODULE)
    
    //Comparison Module Outputs
    logic score_ready; // HIGH when comparison made 
    
    game_comparison compare(.clk(clk), .correct_data(correct_data), .score_ready(score_ready),
                    .intersection_data(sensor_data),.ready_in(ready_in),.correct(correct));
    
                            
    // Score FSM Inputs (score_ready and correct come from game_comparison)
    logic game_over; // HIGH when the game is over (COMES FROM VISUAL MODULE)
    
    //Score FSM Output
    score_fsm update_score(.clk(clk), .start(start), .rst_in(reset), .game_over(game_over), 
                           .score_ready(score_ready), .correct(correct),
                           .updated_score(score));
    
    
endmodule
