`timescale 1ns / 1ps

module top_level(
   input clk_100mhz,
   input[15:0] sw,
   input[7:0] jb,
   
   output[15:0] led,
   
   output[3:0] vga_r,
   output[3:0] vga_b,
   output[3:0] vga_g,
   output vga_hs,
   output vga_vs,
   output ca, cb, cc, cd, ce, cf, cg,  // segments a-g
   output[7:0] an    // Display location 0-7
    );
    logic clk_65mhz;
    // create 65mhz system clock, happens to match 1024 x 768 XVGA timing
    clk_wiz_lab3 clkdivider(.clk_in1(clk_100mhz), .clk_out1(clk_65mhz));
    
    //xvga for selector and visual modules
    wire [10:0] hcount;    // pixel on current line
    wire [9:0] vcount;     // line number
    wire hsync, vsync;
    logic blank;
    xvga xvga1(.vclock_in(clk_65mhz),.hcount_out(hcount),.vcount_out(vcount),
          .hsync_out(hsync),.vsync_out(vsync),.blank_out(blank));
    
    //selector integration
    reg[3:0] speed;
    wire [11:0] menu_pixels;
    wire phsync_m,pvsync_m,pblank_m;
    selector select(.clk(clk_65mhz), .hcount(hcount),.vcount(vcount),
                    .hsync(hsync), .vsync(vsync), .blank(blank),
                    .level(sw[1:0]),.start(sw[15]),
                    .speed(speed),.menu_pixels(menu_pixels),
                    .phsync_out(phsync_m),.pvsync_out(pvsync_m),.pblank_out(pblank_m));
    
    //sensor integration
    wire[5:0] test_sensors;
    wire[8:0] out_data;
    sensor s(.clk(clk_65mhz), .jb_sensors(jb[5:0]),.test_sensors(test_sensors), .out_data(out_data));
    assign led[5:0] = test_sensors;
    
    //visual integration
    wire phsync_vis,pvsync_vis,pblank_vis;
    wire[11:0] visual_pixels;
    visual v(.clk(clk_65mhz), .pvsync(pvsync_vis), .phsync(phsync_vis), .pblank(pblank_vis),
            .ready_start(sw[15]), .speed(speed),
            .vcount(vcount), .hcount(hcount), .hsync(hsync), .vsync(vsync), .blank(blank),
            .visual_pixels(visual_pixels));
    reg b,hs,vs;
    reg [11:0] rgb;
    always_ff @(posedge clk_65mhz) begin
         // default: pong
         if (sw[15]) begin 
            hs <= phsync_vis;
            vs <= pvsync_vis;
            b <= pblank_vis;
            rgb <= visual_pixels;
         end else begin
             hs <= phsync_m;
             vs <= pvsync_m;
             b <= pblank_m;
             rgb <= menu_pixels;
        end
    end
    
    // the following lines are required for the Nexys4 VGA circuit - do not change
    assign vga_r = ~b ? rgb[11:8]: 0;
    assign vga_g = ~b ? rgb[7:4] : 0;
    assign vga_b = ~b ? rgb[3:0] : 0;

    assign vga_hs = ~hs;
    assign vga_vs = ~vs;
    
    wire [31:0] data_display;      //  instantiate 7-segment display; display (8) 4-bit hex
    wire [6:0] segments;
    assign {cg, cf, ce, cd, cc, cb, ca} = segments[6:0];
    display_8hex hex8(.clk_in(clk_65mhz),.data_in(data_display), .seg_out(segments), .strobe_out(an));
    

//    assign data_display = {3'b00,out_data[8],
//                            3'b00,out_data[7],
//                            3'b00,out_data[6],
//                            3'b00,out_data[5],
//                            3'b00,out_data[3],
//                            3'b00,out_data[2],
//                            3'b00,out_data[1],
//                            3'b00,out_data[0]}; 
    assign data_display = {20'b0, rgb};
    
endmodule
