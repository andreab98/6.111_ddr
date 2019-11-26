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
                    
        output[11:0] menu_pixels,
        output logic[3:0] speed  
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
    
    // menu pixels
    logic[10:0] x_begin = 11'd300;
    logic[9:0] y_begin = 10'd200; 
    
    wire[11:0] menu_p;
    menu_blob m(.pixel_clk_in(clk),.x_in(x_begin),.hcount_in(hcount),.y_in(y_begin),.vcount_in(vcount),
                        .pixel_out(menu_p));
    
    assign menu_pixels = menu_p;

endmodule