`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
////
//// display: movement of arrows 
////
//////////////////////////////////////////////////////////////////////////////////

module display (
   input vclock_in,        // 65MHz clock
   input [10:0] hcount_in, // horizontal index of current pixel (0..1023)
   input [9:0]  vcount_in, // vertical index of current pixel (0..767)
   input hsync_in,         // XVGA horizontal sync signal (active low)
   input vsync_in,         // XVGA vertical sync signal (active low)
   input blank_in,         // XVGA blanking (1 means output black pixel)
   
   input[8:0] sensor_data,
   input reset,
   input[3:0] speed,
   input ready_start,
   input[19:0] wait_time, 
      
   output game_over, //game over signal
        
   output phsync_out,
   output pvsync_out,    
   output pblank_out,  
   output [11:0] arrow_pixels 
   );

    assign phsync_out = hsync_in;
    assign pvsync_out = vsync_in;
    assign pblank_out = blank_in;
    
    parameter Y_INIT = 600;
    
    logic[11:0] y = Y_INIT;
    
    logic[10:0] N_arrow_x = 11'd0; 
    logic[10:0] S_arrow_x = 11'd123; 
    logic[10:0] W_arrow_x = 11'd246; 
    logic[10:0] E_arrow_x = 11'd369; 
    logic[10:0] NE_arrow_x = 11'd492; 
    logic[10:0] NW_arrow_x = 11'd615; 
    logic[10:0] SE_arrow_x = 11'd738; 
    logic[10:0] SW_arrow_x = 11'd861; 
    
    logic done;
    
    logic[11:0] color =  12'hFFF;
        
    // read new choreo line 
    logic [15:0] image = 0;   
    logic [8:0] image_bits;
   
    logic[15:0] image_addr;
    // calculate rom address and read the location
    assign image_addr = image;
   
    choreo steps(.clka(vsync_in), .addra(image_addr), .douta(image_bits));
       
    parameter IDLE = 0;
    parameter MOVING_UP = 1;
//    parameter RESET = 2;
    parameter GAME_OVER = 3;
    parameter CHECK = 4;
    parameter READ_DATA =5;
    parameter GET_DATA =6;
    parameter COLOR_CHECK = 7;
        
    // max number of choreo steps 
    parameter MAX_NUM = 5;
    
    logic nw,n,ne,e,se,s,sw,w;
    logic[8:0] correct_data;
    logic ready_in;
    logic correct;
    game_comparison compare(.clk(vclock_in), .correct_data(correct_data), 
                    .intersection_data(sensor_data),.ready_in(ready_in),.correct(correct));
    
    reg[3:0] state = 0;
    always_ff @(posedge vsync_in) begin
        case(state)  
            IDLE: begin 
	           if (ready_start) state<= READ_DATA;
            end
	        READ_DATA: begin 
	           if (image==MAX_NUM) state<= GAME_OVER;
	           else begin
                   image <= image+1;
                   state <= GET_DATA;
               end
            end
            GET_DATA: begin 
                nw <= image_bits[0]; //A NW 
                n <= image_bits[1]; //b N
                ne <= image_bits[2]; //C NE
                w <= image_bits[3]; //D W
                e <= image_bits[5]; //F E
                sw <= image_bits[6]; //G SW
                s <= image_bits[7]; //H S
                se <= image_bits[8]; //I SE       
                state<=MOVING_UP;   
            end
             MOVING_UP: begin
                y <= y-speed;
                if (y<=20) state<= CHECK;
            end
            CHECK: begin 
               ready_in <= 1; 
               correct_data <= image_bits;
               state <= COLOR_CHECK;
		       y <= Y_INIT;
            end
            COLOR_CHECK: begin 
                if (correct) color <= 12'h0F0;
                else color <= 12'hF00;
                state<=READ_DATA;
                ready_in <= 0;
            end
            GAME_OVER: begin 
                
            end
            default: state <= IDLE;
        endcase
    end
    
    // up arrow code
    wire [11:0] n_pixels;
    N_arrow_blob up(.pixel_clk_in(vclock_in),.x_in(N_arrow_x),.y_in(y),
                            .hcount_in(hcount_in),.vcount_in(vcount_in),
                            .pixel_out(n_pixels),.on(n));
                            
    // west arrow code
    wire [11:0] w_pixels;
    W_arrow_blob west(.pixel_clk_in(vclock_in),.x_in(W_arrow_x),.y_in(y),
                            .hcount_in(hcount_in),.vcount_in(vcount_in),
                            .pixel_out(w_pixels),.on(w));
                            
    // south arrow code
    wire [11:0] s_pixels;
    S_arrow_blob south(.pixel_clk_in(vclock_in),.x_in(S_arrow_x),.y_in(y),
                            .hcount_in(hcount_in),.vcount_in(vcount_in),
                            .pixel_out(s_pixels),.on(s));
                            
   // east arrow code
    wire [11:0] e_pixels;
    E_arrow_blob east(.pixel_clk_in(vclock_in),.x_in(E_arrow_x),.y_in(y),
                            .hcount_in(hcount_in),.vcount_in(vcount_in),
                            .pixel_out(e_pixels),.on(e));
                            
    // finish line code
    wire[11:0] finish_line;
    finish_blob finish(.x_in(0),.hcount_in(hcount_in),.y_in(0),.vcount_in(vcount_in),
                        .color(color),.pixel_out(finish_line));
    
    
    assign game_over = done;
    assign arrow_pixels = finish_line + n_pixels + w_pixels + s_pixels +e_pixels;
    
endmodule

//////////////////////////////////////////////////////////////////////
//
// blob: generate rectangle on screen
//
//////////////////////////////////////////////////////////////////////
module finish_blob
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
