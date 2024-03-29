`timescale 1ns / 1ps
///////////////////////////////////////////////////////////////////
//                                                               //
// selector: determines the game state based on the level chosen //
//                                                               //
///////////////////////////////////////////////////////////////////

module selector(
        input clk,
        input reset,
        input[1:0] level,
        input start,
        input[10:0] hcount,
        input[9:0] vcount,
        input hsync,vsync,blank,
        
        
        output phsync_out,
        output pvsync_out,    
        output pblank_out, 
                    
        output [11:0] menu_pixels,
        output [4:0] speed,
        output game_ready,
        output [11:0] max_steps
    );
    
    assign phsync_out = hsync;
    assign pvsync_out = vsync;
    assign pblank_out = blank;
    
    // parameters for speed and max steps based on level
    
    //levels
    parameter LEVEL_1 = 2'b01; // basic
    parameter LEVEL_2 = 2'b10; // difficult
    parameter LEVEL_3 = 2'b11; // expert
    
    // speeds 
    parameter SPEED_1 = 2;
    parameter SPEED_2 = 4;
    parameter SPEED_3 = 8;
    
    // max steps per game - proportional to the speed of the arrows
    parameter MAX_1 = 50;
    parameter MAX_2 = 70;
    parameter MAX_3 = 100;
    
    logic game_start = 0;
    logic[4:0] s; // assigned speed 
    logic[10:0] max = 0;
    
    reg[3:0] state= 0;
    
    // system states
    parameter IDLE = 0;
    parameter LEVEL_CHOOSE = 1;
    parameter DONE = 2;
    parameter RESET = 3;
    
    
    // timer inputs/ouputs to be able to create the loading 
    logic expired; 
    logic counting;
    logic one_hz; 
    logic [3:0] count_out;  
    
    //timer module 
    timer countdown(.clock(clk), .start_timer(reset), .value(4'd6),.counting(counting), 
                    .expired_pulse(expired), .one_hz(one_hz), .count_out(count_out));
    
    
    always_ff @(posedge clk) begin 
        if (reset) begin // system reset
            state<=RESET;
        end else begin
            case (state)
                IDLE: if(start) state<=LEVEL_CHOOSE;
                RESET: begin // system reset
                    game_start<=0;
                    state<=IDLE;
                end
                LEVEL_CHOOSE: begin // choose level 
                    case (level) 
                        LEVEL_1:begin
                            s <= SPEED_1;
                            max<=MAX_1;
                        end
                        LEVEL_2: begin 
                            s <= SPEED_2;
                            max<=MAX_2;
                        end
                        LEVEL_3:begin
                            s<= SPEED_3;
                            max<=MAX_3;
                        end
                    endcase
                    state<=DONE;
                end
                DONE: game_start<=1; 
            endcase
        end
    end
    
    assign speed = s;
    assign game_ready = game_start;
    assign max_steps = max;
    
    // menu pixels
    logic[10:0] x_begin = 11'd300;
    logic[9:0] y_begin = 10'd200; 
    wire[11:0] menu_p;
    menu_blob m(.pixel_clk_in(clk),.x_in(x_begin),.hcount_in(hcount),.y_in(y_begin),.vcount_in(vcount),
                        .pixel_out(menu_p));
                        
    // loading pixels
    wire [11:0] loading_pixels;
    logic[10:0] loading_x = 11'd320;
    logic [9:0] loading_y = 10'd500;
    loading_blob load(.pixel_clk_in(clk), .x_in(loading_x), .hcount_in(hcount), .y_in(loading_y), 
                    .vcount_in(vcount), .pixel_out(loading_pixels), .on(counting));

    // final output pixels
    assign menu_pixels = menu_p + loading_pixels;

endmodule
