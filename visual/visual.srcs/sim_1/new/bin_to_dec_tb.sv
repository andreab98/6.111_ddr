`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 12/05/2019 05:04:48 PM
// Design Name: 
// Module Name: bin_to_dec_tb
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


module bin_to_dec_tb;
    logic [9:0] score;
    logic [3:0] tens;
    logic [3:0] hundreds;
    logic [3:0] ones; 

    bin_to_dec uut(.number(score), .tens(tens), .hundreds(hundreds), .ones(ones));
    
    initial begin
      // Initialize Inputs
      #5
      score = 999;
      #10
      score = 5;
      #10 
      score = 200;
      #10 
      score = 10;
      
      
    end 
endmodule
