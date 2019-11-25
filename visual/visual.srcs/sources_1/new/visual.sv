`timescale 1ns / 1ps

module visual(
   input clk,
   input[3:0] speed,
   input ready_start,
   
   output phsync,pvsync,pblank,
   output[11:0] visual_pixels
   );
  
    wire [10:0] hcount;    // pixel on current line
    wire [9:0] vcount;     // line number
    wire hsync, vsync;
    logic blank;
    xvga xvga1(.vclock_in(clk),.hcount_out(hcount),.vcount_out(vcount),
          .hsync_out(hsync),.vsync_out(vsync),.blank_out(blank));
    
    wire[3:0] state;
    wire[3:0] nesw;
    wire[11:0] arrow_pixels;
    display a(.vclock_in(clk),
                .hcount_in(hcount),.vcount_in(vcount),
                .hsync_in(hsync),.vsync_in(vsync),.blank_in(blank),
                .speed(speed),.ready_start(ready_start),
                .phsync_out(phsync),.pvsync_out(pvsync),.pblank_out(pblank),.arrow_pixels(arrow_pixels));
    
    assign visual_pixels = arrow_pixels;
endmodule