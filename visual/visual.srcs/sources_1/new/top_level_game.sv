`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 11/17/2019 04:47:01 PM
// Design Name: 
// Module Name: top_level_game
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


module top_level_game(input clk_100mhz, // system clock
                      input btnr, // system reset
                      input btnc, // games start (might not need this)
                      
                      output logic [7:0] an,
                      output logic ca, 
                      output logic cb, 
                      output logic cc, 
                      output logic cd, 
                      output logic ce,
                      output logic cf, 
                      output logic cg
                      
                      
    );
    
    //Comparison Module Inputs
    logic [8:0] correct_data; // data stored in memory (COMES FROM VISUAL MODULE)
    logic [8:0] intersection_data; // data from sensors -- player's actions (COMES FROM SENSOR MODULE)
    logic ready_in; // HIGH when arrow passes threshold on screen (COMES FROM VISUAL MODULE)
    
    //Comparison Module Outputs
    logic score_ready; // HIGH when comparison made 
    logic correct; // HIGH when the player stepped correctly
    
    
    game_comparison compare(.clk(clk_100mhz), .correct_data(correct_data), 
                            .intersection_data(intersection_data), .ready_in(ready_in),
                            .score_ready(score_ready), .correct(correct));
                            
    // Score FSM Inputs (score_ready and correct come from game_comparison)
    logic game_over; // HIGH when the game is over (COMES FROM VISUAL MODULE)
    
    //Score FSM Output
    logic [31:0] score; //score of the game 
    
    score_fsm update_score(.clk(clk_100mhz), .start(btnc), .rst_in(btnr), .game_over(game_over), 
                           .score_ready(score_ready), .correct(correct),
                           .updated_score(score));
                           
    // Display score on hex   
    logic [6:0] led_out;                          
    seven_seg_controller seven(.clk_in(clk_100mhz), .rst_in(btnr), .val_in(score), .cat_out(), .an_out(an));
    assign {cg, cf, ce, cd, cc, cb, ca} = led_out;    
endmodule
