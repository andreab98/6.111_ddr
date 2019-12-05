`timescale 1ns / 1ps

module game_comparison(input clk,
                       input [4:0] correct_data,
                       input [4:0] intersection_data,
                       input ready_in, 
                       
                       output logic score_ready, 
                       output logic correct
    );
    
    parameter IDLE = 0;
    parameter READY_FINAL = 1;
    
    reg[2:0] state = 0;
    
    logic prev_ready;
    
    always_ff @(posedge clk) begin 
        case(state)
            IDLE: begin 
                prev_ready <= ready_in;
                if (ready_in && !prev_ready) begin 
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
