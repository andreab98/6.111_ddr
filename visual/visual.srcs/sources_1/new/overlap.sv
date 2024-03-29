`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
//
// overlap: determine which squares are stepped on at the moment 
//
//////////////////////////////////////////////////////////////////////////////////

module overlap(
    input clk,
    input clean_0,
    input clean_1,
    input clean_2,
    input clean_3,
    input clean_4,
    input clean_5,
    
    output logic[4:0] intersection_data
    );

    always_comb begin 
        intersection_data[4] = (clean_1 && clean_3); // morth A
        intersection_data[3] = (clean_0 && clean_4); // west B
        intersection_data[2] = 0; // center should be 0 to match choreo and give users more flexiobity on where to step
        intersection_data[1] = (clean_2 && clean_4); // east D
        intersection_data[0] = (clean_1 && clean_5); // south E
    end
    
endmodule
