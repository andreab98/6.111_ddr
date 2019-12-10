`timescale 1ns / 1ps

//////////////////////////////////////////////////////////////////////////////////
//
//  visual: movement of arrows 
//
//////////////////////////////////////////////////////////////////////////////////

module visual (
   input clk,        // 65MHz clock
   input [10:0] hcount, // horizontal index of current pixel (0..1023)
   input [9:0]  vcount, // vertical index of current pixel (0..767)
   input hsync,         // XVGA horizontal sync signal (active low)
   input vsync,         // XVGA vertical sync signal (active low)
   input blank,         // XVGA blanking (1 means output black pixel)
   
   input reset, pause, ready_start, // system inputs
   input[4:0] speed, // speed of arrows
   input [31:0] score, // current score to display
   input streak,  
   input correct,
   input[11:0] max_num, //number of steps before game_over
   
   output perfect, // if perfect
   output logic [4:0] correct_data, // corect data at the top of the screen
   output logic ready_in, // check against sensor data signal
   output game_over, //game over signal
   
   // visual output parameters
   output phsync,
   output pvsync,    
   output pblank,  
   output [11:0] arrow_pixels 
   );
                
    assign phsync = hsync;
    assign pvsync = vsync;
    assign pblank = blank;
    
    // initial y param for arrows
    parameter Y_INIT = 600;
    logic[11:0] y = Y_INIT;
    
    // x location for arrows
    parameter N_ARROW_X = 100; 
    parameter S_ARROW_X = 223; 
    parameter W_ARROW_X = 346; 
    parameter E_ARROW_X = 469; 

    // x location for score blobs
    parameter SCORE_1_X = 764; 
    parameter SCORE_2_X = 814; 
    parameter SCORE_3_X = 864;
    
    // x location for Streak and Perfect blobs
    parameter STR_PERF_X = 750;
    
    // game over variable
    logic done = 0;
    
    logic[11:0] color =  12'hFFF; // initialize bar as white
        
    // read new choreo line 
    logic [15:0] image = 0;   
    logic [4:0] image_bits;
    
    // calculate rom address and read the location
    logic[15:0] image_addr;
    assign image_addr = image;
    
    logic [4:0] prev_image = 0;
    
    // uncomment to use choreo with only one step at a time
    //choreo steps(.clka(vsync), .addra(image_addr), .douta(image_bits));
    
    // includes two steps at a time 
    fun_choreo dance(.clka(vsync), .addra(image_addr), .douta(image_bits));   
    
    // define states
    parameter IDLE = 0;
    parameter MOVING_UP = 1;
    parameter RESET = 2;
    parameter READ_DATA =3;
    parameter GET_DATA =4;
    parameter COLOR_CHECK = 5;
    parameter PAUSE = 6;
    parameter CHECK_PERFECT = 7;
    parameter CHECK_IMPERFECT = 8;
    parameter CHECK_WAIT = 9;
    parameter PERFECT_WAIT = 10;
    parameter GAME_OVER = 11;
        
    parameter Y_PERFECT = 163;
    parameter Y_MARGIN = 10;
        
    logic n,e,s,w;
    
    logic prev_pause = 0;
    logic perfect_curr;
    logic correct_curr;
        
    reg[4:0] state = 0;
    logic curr_streak;
    always_ff @(posedge vsync) begin
        curr_streak <= streak;
        if (reset) begin 
            state<= RESET;
        end else begin
            case(state)  
                IDLE: begin 
                   y <= Y_INIT; 
                   if (ready_start) begin 
                    state<= READ_DATA;
                    ready_in <= 0;
                   end
                end
                RESET: begin 
                    image <= 0; // reset image address
                    color <= 12'hFFF; //reset back to white
                    state<=IDLE;
                    ready_in <= 0;
                    perfect_curr<=0;
                end
                GAME_OVER: begin 
                    if (reset) state<= RESET;
                end
                PAUSE: begin
                    ready_in <= 0;
                    prev_pause <= pause;
                    if (pause && (!prev_pause)) state<=MOVING_UP; //game paused
                end
                READ_DATA: begin 
                   prev_image <= image_bits;
                   ready_in <= 0;
                   if (image>=max_num) begin 
                        state <= GAME_OVER;
                        done <= 1;
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
                    y<=Y_INIT; 
                end
                MOVING_UP: begin
                    ready_in <= 0;
                    y <= y - speed;

                    // check perfect vs imperfect
                    if (y <= (Y_PERFECT+Y_MARGIN)) begin 
                        if (y >= Y_PERFECT) state<=CHECK_PERFECT;
                        else state<=CHECK_IMPERFECT;
                    end
                    
                    prev_pause <= pause;
                    if (pause && (!prev_pause)) state<=PAUSE; //game paused
                end
                CHECK_IMPERFECT: begin 
                    ready_in <= 1;
                    correct_data <= prev_image;
                    state<=CHECK_WAIT;
                    perfect_curr <= 0;
                end
                CHECK_WAIT: begin
                    ready_in <= 0;
                    if(correct || (y<50)) begin 
                        correct_curr <= correct;
                        state <= COLOR_CHECK;
                    end else begin 
                        y <= y - speed;
                        state<= MOVING_UP;
                    end
                end
                CHECK_PERFECT: begin 
                    perfect_curr <= 1;
                    ready_in <= 1;
                    correct_data <= prev_image;
                    state<= PERFECT_WAIT;
                end
                PERFECT_WAIT: begin
                    ready_in <= 0;
                    if (correct) begin 
                        state<= COLOR_CHECK;
                        correct_curr <= correct;
                    end else begin 
                        y <= y - speed;
                        state <= MOVING_UP;
                    end
                end
                COLOR_CHECK: begin 
                    ready_in <= 0;
                    if (correct_curr) color <= 12'h0F0;
                    else begin
                        color <= 12'hF00;
                    end
                    state<=READ_DATA;
                end
                default: state <= IDLE;
            endcase
        end
    end
    
    // game over code
    wire [11:0] done_pixels;
    game_over_blob go(.pixel_clk_in(clk), .x_in(150), .y_in(300), 
                     .hcount_in(hcount), .vcount_in(vcount),
                     .pixel_out(done_pixels), .on(done));
    
    // determine score and display using 3 numbers (000 to 999)
    logic [4:0] hundreds;
    logic [4:0] tens; 
    logic [4:0] ones;
    bin_to_dec convert(.number(score), .hundreds(hundreds), .tens(tens), .ones(ones));
  
    parameter SCORE_HEIGHT = 100; 
    parameter STREAK_HEIGHT = 300;
    parameter PERFECT_HEIGHT = 400;
    
    wire [11:0] score_pixels_1;
    score_blob_1 score1(.pixel_clk_in(clk), .x_in(SCORE_1_X), .y_in(SCORE_HEIGHT), 
                     .hcount_in(hcount), .vcount_in(vcount),
                     .pixel_out(score_pixels_1), .num(hundreds));
    
    wire [11:0] score_pixels_2;
    score_blob_2 score2(.pixel_clk_in(clk), .x_in(SCORE_2_X), .y_in(SCORE_HEIGHT), 
                     .hcount_in(hcount), .vcount_in(vcount), 
                     .pixel_out(score_pixels_2), .num(tens));
                      
    wire [11:0] score_pixels_3;
    score_blob_3 score3(.pixel_clk_in(clk), .x_in(SCORE_3_X), .y_in(SCORE_HEIGHT), 
                     .hcount_in(hcount), .vcount_in(vcount), 
                     .pixel_out(score_pixels_3), .num(ones));
                     
    // up arrow code
    wire [11:0] n_pixels;
    N_arrow_blob up(.pixel_clk_in(clk),.x_in(N_ARROW_X),.y_in(y),
                            .hcount_in(hcount),.vcount_in(vcount),
                            .pixel_out(n_pixels),.on(n));
                            
    // west arrow code
    wire [11:0] w_pixels;
    W_arrow_blob west(.pixel_clk_in(clk),.x_in(W_ARROW_X),.y_in(y),
                            .hcount_in(hcount),.vcount_in(vcount),
                            .pixel_out(w_pixels),.on(w));
                            
    // south arrow code
    wire [11:0] s_pixels;
    S_arrow_blob south(.pixel_clk_in(clk),.x_in(S_ARROW_X),.y_in(y),
                            .hcount_in(hcount),.vcount_in(vcount),
                            .pixel_out(s_pixels),.on(s));
                            
   // east arrow code
    wire [11:0] e_pixels;
    E_arrow_blob east(.pixel_clk_in(clk),.x_in(E_ARROW_X),.y_in(y),
                            .hcount_in(hcount),.vcount_in(vcount),
                            .pixel_out(e_pixels),.on(e));
                            
    // finish line code
    wire[11:0] finish_line;
    rectangle_blob finish(.x_in(0),.hcount_in(hcount),.y_in(42),.vcount_in(vcount),
                        .color(color),.pixel_out(finish_line));
    
    // perfect vs imperfect line;
    wire[11:0] perfect_line; // line is blue
    rectangle_blob #(.HEIGHT(113)) 
            perfect_blob(.x_in(0),.hcount_in(hcount),.y_in(163),.vcount_in(vcount),
                        .color(12'h2EF),.pixel_out(perfect_line));

    // alpha blending for perfect line and arrows
    logic[11:0] arrow_p;
    logic[11:0] blended_pixels;
    logic[3:0] r_pixels,b_pixels,g_pixels;
    assign arrow_p = n_pixels + w_pixels + s_pixels +e_pixels; 
    always_comb begin 
        r_pixels = arrow_p[11:8] + 3*(perfect_line[11:8]>>2);
        g_pixels = arrow_p[7:4] + 3*(perfect_line[7:4]>>2);
        b_pixels = arrow_p[3:0] + 3*(perfect_line[3:0]>>2);
        blended_pixels = {r_pixels,g_pixels,b_pixels};
    end
    
    assign perfect = perfect_curr;
    assign game_over = done;
    
    // streak code    
    wire [11:0] streak_pixels;
    streak_blob str(.pixel_clk_in(clk),.x_in(STR_PERF_X),.y_in(STREAK_HEIGHT),
                            .hcount_in(hcount),.vcount_in(vcount),
                            .pixel_out(streak_pixels),.on((streak ||curr_streak)));

    // perfect bonus pixels
    wire [11:0] perfect_pixels;
    perfect_bonus_blob bonus(.pixel_clk_in(clk),.x_in(STR_PERF_X),.y_in(PERFECT_HEIGHT),
                            .hcount_in(hcount),.vcount_in(vcount),
                            .pixel_out(perfect_pixels),.on((correct && perfect)));
    
    // output pixels includin all blobs
    assign arrow_pixels = finish_line + blended_pixels + done_pixels +
                        score_pixels_1 + score_pixels_2 + score_pixels_3 + streak_pixels + perfect_pixels;

endmodule

//////////////////////////////////////////////////////////////////////
//
// blob: generate rectangle on screen
//
//////////////////////////////////////////////////////////////////////
module rectangle_blob
   #(parameter WIDTH = 1048,   
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
