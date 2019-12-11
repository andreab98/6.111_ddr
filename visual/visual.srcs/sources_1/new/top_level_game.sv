`timescale 1ns / 1ps

module top_level_game(input clk, // system clock
                      input reset, // system reset
                      input start, // games start (might not need this)
                      
                      input perfect_check,
                      input game_over,
                      
                      input [4:0] sensor_data, // data from sensors -- player's actions 
                      input [4:0] correct_data, // data stored in memory 
                      input ready_in, //HIGH when arrow passes threshold on screen
                      
                      output logic correct,
                      output logic streak,
                      output logic [31:0] score,
                      
                      //debugging
                      output logic i
                       
    );

    //Comparison Module Outputs
    logic score_ready; // HIGH when comparison made 
    
    // Module that handles comparison between input data from sensors and correct data from ROM
    game_comparison compare(.clk(clk), .correct_data(correct_data), .score_ready(score_ready),
                    .intersection_data(sensor_data),.ready_in(ready_in),.correct(correct));
      
    //Score FSM Output
    score_fsm update_score(.clk(clk), .start(start), .rst_in(reset), .game_over(game_over),
                           .score_ready(score_ready), .correct(correct), .perfect(perfect_check),.streak_out(streak),
                           .updated_score(score));
    
    assign i = score_ready;
endmodule
