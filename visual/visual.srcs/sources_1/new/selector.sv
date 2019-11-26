`timescale 1ns / 1ps
module selector(
        input clk,
        input[1:0] level,
        input start,
        input[10:0] hcount,
        input[9:0] vcount,
        input hsync,vsync,blank,
        
        output phsync_out,
        output pvsync_out,    
        output pblank_out, 
                    
        output [11:0] menu_pixels,
        output [3:0] speed,
        output game_ready  
    );
    
    assign phsync_out = hsync;
    assign pvsync_out = vsync;
    assign pblank_out = blank;
    
    parameter LEVEL_1 = 2'b01;
    parameter LEVEL_2 = 2'b10;
    parameter LEVEL_3 = 2'b11;
    
    parameter SPEED_1 = 4;
    parameter SPEED_2 = 8;
    parameter SPEED_3 = 16;
    
    logic game_start = 0;
    logic[3:0] s;
    
    reg[2:0] state= 0;
    
    parameter IDLE = 0;
    parameter LEVEL_CHOOSE = 1;
    parameter DONE = 2;
    always_ff @(posedge clk) begin 
        case (state)
            IDLE: if(start) state<=LEVEL_CHOOSE;
            
            LEVEL_CHOOSE: begin
                case (level) 
                    LEVEL_1:begin
                        s <= SPEED_1;
                    end
                    LEVEL_2: begin 
                        s <= SPEED_2;
                    end
                    LEVEL_3:begin
                        s<= SPEED_3;
                    end
                endcase
                state<=DONE;
            end
            DONE: game_start<=1;
        endcase
    end
    
    assign speed = s;
    assign game_ready = game_start;
    
    // menu pixels
    logic[10:0] x_begin = 11'd300;
    logic[9:0] y_begin = 10'd200; 
    
    wire[11:0] menu_p;
    menu_blob m(.pixel_clk_in(clk),.x_in(x_begin),.hcount_in(hcount),.y_in(y_begin),.vcount_in(vcount),
                        .pixel_out(menu_p));
    
    assign menu_pixels = menu_p;

endmodule