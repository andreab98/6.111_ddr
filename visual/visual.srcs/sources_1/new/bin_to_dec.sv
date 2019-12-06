`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 12/05/2019 04:34:17 PM
// Design Name: 
// Module Name: bin_to_dec
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

// Double Dabble Algorithm - my.eng.utah.edu/~nmcdonal/Tutorials/BCDTutorial/BCDConversion.html

module bin_to_dec(input [9:0] number, 
                  output logic [3:0] hundreds, output logic [3:0] tens, output logic [3:0] ones);
                  
              integer i; 
             
              always_comb begin 
                //initialize values 
                hundreds = 4'd0; 
                tens = 4'd0;
                ones = 4'd0;
                
                for (i = 9; i >= 0; i = i-1) begin 
                    // if a value is 5 or greater, add 3
                    if (hundreds > 4) begin 
                        hundreds = hundreds + 3;
                    end 
                    if (tens > 4) begin 
                        tens = tens + 3;
                    end 
                    if (ones > 4) begin 
                        ones = ones + 3;
                    end 
                    
                    // shift each value to the left 
                    hundreds = hundreds << 1;
                    hundreds[0] = tens[3];
                    tens = tens << 1; 
                    tens[0] = ones[3];
                    ones = ones << 1; 
                    ones[0] = number[i];
                end
              end 

    endmodule
