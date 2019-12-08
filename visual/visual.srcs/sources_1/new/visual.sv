
`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
////
//// visual: movement of arrows 
////
//////////////////////////////////////////////////////////////////////////////////

module visual (
   input clk,        // 65MHz clock
   input [10:0] hcount, // horizontal index of current pixel (0..1023)
   input [9:0]  vcount, // vertical index of current pixel (0..767)
   input hsync,         // XVGA horizontal sync signal (active low)
   input vsync,         // XVGA vertical sync signal (active low)
   input blank,         // XVGA blanking (1 means output black pixel)
   
   input[4:0] sensor_data,
   input reset, pause, start,
   input[4:0] speed,
   input ready_start,
   input [31:0] score,
   input streak,    
   input correct,
   output logic [4:0] correct_data,
   output logic ready_in,   
   
   output game_over, //game over signal
   
   output phsync,
   output pvsync,    
   output pblank,  
   output [11:0] arrow_pixels 
   );

    assign phsync = hsync;
    assign pvsync = vsync;
    assign pblank = blank;
    
    parameter Y_INIT = 600;
    
    logic[11:0] y = Y_INIT;
    
    logic[10:0] N_arrow_x = 11'd100; 
    logic[10:0] S_arrow_x = 11'd223; 
    logic[10:0] W_arrow_x = 11'd346; 
    logic[10:0] E_arrow_x = 11'd469; 

    logic [10:0] score_1_x = 11'd764; 
    logic [10:0] score_2_x = 11'd814; 
    logic [10:0] score_3_x = 11'd864;
    
    logic[10:0] streak_x = 11'd750;
    
    logic done = 0;
    
    logic[11:0] color =  12'hFFF;
        
    // read new choreo line 
    logic [15:0] image = 0;   
    logic [4:0] image_bits;
   
    logic[15:0] image_addr;
    // calculate rom address and read the location
    assign image_addr = image;
    
    logic [4:0] prev_image = 0;
   
    choreo steps(.clka(vsync), .addra(image_addr), .douta(image_bits));
       
    parameter IDLE = 0;
    parameter MOVING_UP = 1;
    parameter RESET = 2;
    parameter CHECK = 4;
    parameter READ_DATA =5;
    parameter GET_DATA =6;
    parameter COLOR_CHECK = 7;
    parameter PAUSE = 8;
        
    // max number of choreo steps 
    parameter MAX_NUM = 110;
    
    logic n,e,s,w;
    
    logic prev_pause = 0;
    
    reg[4:0] state = 0;
    always_ff @(posedge vsync) begin
        if (reset) begin 
            state<= RESET;
        end else begin
            case(state)  
                IDLE: begin 
                   if (ready_start) begin 
                    state<= READ_DATA;
                    ready_in <= 0;
                   end
                end
                RESET: begin 
                    image <= 0; // reset image address
                    color <= 12'hFFF; //reset back to white
                    y <= Y_INIT;
                    state<=IDLE;
                    ready_in <= 0;
                end
                PAUSE: begin
                    ready_in <= 0;
                    prev_pause <= pause;
                    if (pause && (!prev_pause)) state<=MOVING_UP; //game paused
                end
                READ_DATA: begin 
                   prev_image <= image_bits;
                   ready_in <= 0;
                   if (image==MAX_NUM) begin 
                        state<= RESET;
                        done<=1;
                   end else begin
                       image <= image+1;
                       state <= GET_DATA;
                       done <= 0;
                   end
                end
                GET_DATA: begin 
                    n <= image_bits[4]; //b N
                    w <= image_bits[3]; //D W
                    e <= image_bits[1]; //F E
                    s <= image_bits[0]; //H S
                    state<=MOVING_UP; 
                    ready_in <= 0;  
                end
                 MOVING_UP: begin
                    ready_in <= 0;
                    y <= y - speed;
                    if (y<=46) state<= CHECK;
                    prev_pause <= pause;
                    if (pause && (!prev_pause)) state<=PAUSE; //game paused
                end
                CHECK: begin 
                   ready_in <= 1; 
                   correct_data <= prev_image;
                   state <= COLOR_CHECK;
                   y <= Y_INIT;
                end
                COLOR_CHECK: begin 
                    ready_in <= 0;
                    if (correct) color <= 12'h0F0;
                    else color <= 12'hF00;
                    state<=READ_DATA;
                end
                default: state <= IDLE;
            endcase
        end
    end
    
    logic [4:0] hundreds;
    logic [4:0] tens; 
    logic [4:0] ones;
    bin_to_dec convert(.number(score), .hundreds(hundreds), .tens(tens), .ones(ones));
    
    parameter score_height = 200; 
    parameter streak_height = 300;
    
    wire [11:0] score_pixels_1;
    score_blob_1 score1(.pixel_clk_in(clk), .x_in(score_1_x), .y_in(score_height), 
                     .hcount_in(hcount), .vcount_in(vcount), 
                     .pixel_out(score_pixels_1), .num(hundreds));
    
    wire [11:0] score_pixels_2;
    score_blob_2 score2(.pixel_clk_in(clk), .x_in(score_2_x), .y_in(score_height), 
                     .hcount_in(hcount), .vcount_in(vcount), 
                     .pixel_out(score_pixels_2), .num(tens));
                      
    wire [11:0] score_pixels_3;
    score_blob_3 score3(.pixel_clk_in(clk), .x_in(score_3_x), .y_in(score_height), 
                     .hcount_in(hcount), .vcount_in(vcount), 
                     .pixel_out(score_pixels_3), .num(ones));
                     
    // up arrow code
    wire [11:0] n_pixels;
    N_arrow_blob up(.pixel_clk_in(clk),.x_in(N_arrow_x),.y_in(y),
                            .hcount_in(hcount),.vcount_in(vcount),
                            .pixel_out(n_pixels),.on(n));
                            
    // west arrow code
    wire [11:0] w_pixels;
    W_arrow_blob west(.pixel_clk_in(clk),.x_in(W_arrow_x),.y_in(y),
                            .hcount_in(hcount),.vcount_in(vcount),
                            .pixel_out(w_pixels),.on(w));
                            
    // south arrow code
    wire [11:0] s_pixels;
    S_arrow_blob south(.pixel_clk_in(clk),.x_in(S_arrow_x),.y_in(y),
                            .hcount_in(hcount),.vcount_in(vcount),
                            .pixel_out(s_pixels),.on(s));
                            
   // east arrow code
    wire [11:0] e_pixels;
    E_arrow_blob east(.pixel_clk_in(clk),.x_in(E_arrow_x),.y_in(y),
                            .hcount_in(hcount),.vcount_in(vcount),
                            .pixel_out(e_pixels),.on(e));
                            
    // finish line code
    wire[11:0] finish_line;
    rectangle_blob finish(.x_in(0),.hcount_in(hcount),.y_in(42),.vcount_in(vcount),
                        .color(color),.pixel_out(finish_line));
     
    wire [11:0] streak_pixels;
    streak_blob str(.pixel_clk_in(clk),.x_in(streak_x),.y_in(streak_height),
                            .hcount_in(hcount),.vcount_in(vcount),
                            .pixel_out(streak_pixels),.on(streak));
    

    //perfect vs imperfect line;
    //wire[11:0] perfect_line;
    //rectangle_blob perfect(.x_in(0),.hcount_in(hcount),.y_in(42),.vcount_in(vcount),
                        //.color(color),.pixel_out(finish_line));

//    ila_0 ila (.clk(clk), .probe0(state), .probe1(sensor_data[4:0]),.probe2(correct_data[4:0]),.probe3(ready_in),
//                .probe4(correct),.probe5(0), .probe6(0), .probe7(0));
    
    assign game_over = done;
    assign arrow_pixels = finish_line + n_pixels + w_pixels + s_pixels +e_pixels + score_pixels_1 + score_pixels_2 + score_pixels_3 + streak_pixels;
    
endmodule

//////////////////////////////////////////////////////////////////////
//
// blob: generate rectangle on screen
//
//////////////////////////////////////////////////////////////////////
module rectangle_blob
   #(parameter WIDTH = 900,   
               HEIGHT = 8) 
   (input [10:0] x_in,hcount_in,
    input [9:0] y_in,vcount_in,
    input [11:0] color,
    output logic [11:0] pixel_out);

   always_comb begin
      if ((hcount_in >= x_in && hcount_in < (x_in+WIDTH)) &&
	 (vcount_in >= y_in && vcount_in < (y_in+HEIGHT)))
	pixel_out = color;
      else pixel_out = 0;
   end
endmodule
