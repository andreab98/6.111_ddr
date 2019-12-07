`timescale 1ns / 1ps

module score_tb;

    //Inputs
    logic clk = 0;
    logic reset = 0;
    logic start = 0;
    logic game_over = 0;
    logic ready_in = 0;
    logic[4:0] sensor_data;
    logic[4:0] correct_data;
       
    //outputs
    logic correct;
    logic[31:0] score;
    logic i;
    
    
    top_level_game uut(
        .clk(clk),
        .reset(reset),
        .start(start),
        .game_over(game_over),
        .sensor_data(sensor_data),
        .correct_data(correct_data),
        .ready_in(ready_in),
        .correct(correct),
        .score(score),
        .i(i)
        );
        
    always #5 clk = !clk;
  
    initial begin
        //init inputs 
        start = 1;
        correct_data = 5'b10100;
        sensor_data = 5'b10100;
        
        #5
        ready_in = 1;
        #5
        ready_in = 0;
        
        #5
        ready_in = 1;
        #5
        ready_in = 0;
        
        #5
        ready_in = 1;
        #5
        ready_in = 0;
        
        #5
        ready_in = 1;
        #5
        ready_in = 0;
        
        #5
        ready_in = 1;
        #5
        ready_in = 0;
        
        #5
        ready_in = 1;
        #5
        ready_in = 0;
        
        #5
        ready_in = 1;
        #5
        ready_in = 0;
        
        #5
        ready_in = 1;
        #5
        ready_in = 0;
        #5
        ready_in = 1;
        #5
        ready_in = 0;
        #5
        ready_in = 1;
        #5
        ready_in = 0;
        #5
        ready_in = 1;
        #5
        ready_in = 0;
        
        //make changes
        
        
    
     end
endmodule
