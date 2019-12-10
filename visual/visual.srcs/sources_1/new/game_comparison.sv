`timescale 1ns / 1ps

//////////////////////////////////////////////////////////////////////////////////
//
// game_comparison: determine which squares are stepped on at the moment 
//
//////////////////////////////////////////////////////////////////////////////////

module game_comparison(input clk,
                       input [4:0] correct_data, // choreo data
                       input [4:0] intersection_data, //sensor data
                       input ready_in, //ready signal
                       
                       output logic score_ready, // score update signal
                       output logic correct // correct variable
    );
    
    parameter IDLE = 0;
    parameter READY_FINAL = 1;
    
    reg[2:0] state = 0;
    
    logic prev_ready;
    
    always_ff @(posedge clk) begin 
        case(state)
            IDLE: begin 
                // check for risin edge of ready to check
                prev_ready <= ready_in;
                if (ready_in && !prev_ready) begin 
                    // check for correct and send signal to update score
                    correct <= (intersection_data == correct_data); 
                    score_ready <= 1; 
                    state<=READY_FINAL;
                end 
             end
             READY_FINAL: begin
                score_ready<=0;
                state<=IDLE;
             end
        endcase 
    end
endmodule
