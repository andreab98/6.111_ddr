`timescale 1ns / 1ps

module overlap(
    input clk,
    input clean_0,
    input clean_1,
    input clean_2,
    input clean_3,
    input clean_4,
    input clean_5,
    
    output logic[8:0] intersection_data
    );

    always_comb begin 
        intersection_data[8] = (clean_0 && clean_5); // A
        intersection_data[7] = (clean_0 && clean_4); // B
        intersection_data[6] = (clean_0 && clean_3); // C
        intersection_data[5] = (clean_1 && clean_5); // D
        intersection_data[4] = 0; //E (center square)
        intersection_data[3] = (clean_1 && clean_3); // F
        intersection_data[2] = (clean_2 && clean_5); // G
        intersection_data[1] = (clean_2 && clean_4); // H
        intersection_data[0] = (clean_2 && clean_3); // I
    end
    
endmodule
