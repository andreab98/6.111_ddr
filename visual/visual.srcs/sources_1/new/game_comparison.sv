`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 11/17/2019 05:03:45 PM
// Design Name: 
// Module Name: game_comparison
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


module game_comparison(input clk,
                       input [8:0] correct_data,
                       input [8:0] intersection_data,
                       input ready_in, 
                       
                       output logic score_ready, 
                       output logic correct
    );
    always_ff @(posedge clk) begin 
        if (ready_in) begin 
            correct <= (intersection_data == correct_data); 
            score_ready <= 1; 
        end else begin
            score_ready <= 0;
        end 
    end
endmodule
