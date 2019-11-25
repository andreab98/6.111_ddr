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
    
    //selector integration
    reg[3:0] speed;
    selector select(.clk(clk_65mhz), 
                    .level(sw[1:0]),.start(sw[15]),
                    .speed(speed));
    
    //sensor integration
    wire[5:0] test_sensors;
    sensor s(.clk(clk_65mhz), .jb_sensors(jb[5:0]),.test_sensors(test_sensors));
    assign led[5:0] = test_sensors;
    
    //visual integration
    wire phsync,pvsync,pblank;
    wire[11:0] visual_pixels;
    visual v(.clk(clk_65mhz),.pvsync(pvsync),.phsync(phsync),
            .ready_start(sw[15]),.speed(speed),
            .visual_pixels(visual_pixels));
    reg b,hs,vs;
    reg [11:0] rgb;
    always_ff @(posedge clk_65mhz) begin
         // default: pong
         hs <= phsync;
         vs <= pvsync;
         b <= pblank;
         rgb <= visual_pixels;
    end
    // the following lines are required for the Nexys4 VGA circuit - do not change
    assign vga_r = ~b ? rgb[11:8]: 0;
    assign vga_g = ~b ? rgb[7:4] : 0;
    assign vga_b = ~b ? rgb[3:0] : 0;

    assign vga_hs = ~hs;
    assign vga_vs = ~vs;
endmodule
