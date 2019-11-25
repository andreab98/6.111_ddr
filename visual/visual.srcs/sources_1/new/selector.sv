`timescale 1ns / 1ps
module selector(
        input clk,
        input[1:0] level,
        input start,
        
        output[11:0] menu_pixels,
        output logic[3:0] speed  
    );
    
    parameter LEVEL_1 = 2'b01;
    parameter LEVEL_2 = 2'b10;
    parameter LEVEL_3 = 2'b11;
    
    parameter SPEED_1 = 4;
    parameter SPEED_2 = 8;
    parameter SPEED_3 = 16;
    
    always_ff @(posedge clk) begin 
        if (start) begin 
            case (level) 
                LEVEL_1:begin
                    speed <= SPEED_1;
                end
                LEVEL_2: begin 
                    speed <= SPEED_2;
                end
                LEVEL_3:begin
                    speed<= SPEED_3;
                end
            endcase
        end
    end
    
    
endmodule