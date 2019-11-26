`timescale 1ns / 1ps

module top_level(
   input clk_100mhz,
   input btnc, // start signal
   input btnr, // system reset
   input sd_cd, // sd card input
   
   input[15:0] sw,
   input[7:0] jb,
   
   inout [3:0] sd_dat, // sd cad
   
   output[15:0] led, // for debugging
   
   output[3:0] vga_r,
   output[3:0] vga_b,
   output[3:0] vga_g,
   output vga_hs,
   output vga_vs,
   output ca, cb, cc, cd, ce, cf, cg,  // segments a-g
   output[7:0] an,    // Display location 0-7
   
   //sd card outputs 
   output logic sd_reset, 
   output logic sd_sck, 
   output logic sd_cmd,
   
   //audio outputs
   output logic aud_sd, 
   output logic aud_pwm
    );
    
    logic clk_100mhz_out;
    logic clk_25mhz; // for sd card
    logic clk_65mhz; // for visual
    clk_wiz_0 make_clocks(.clk_in1(clk_100mhz),.reset(0), .clk_out1(clk_25mhz), .clk_out2(clk_100mhz_out), .clk_out3(clk_65mhz));
    
    logic reset; 
    logic start;
    //debounce button inputs 
    debounce deb_start(.clock_in(clk_100mhz), .noisy_in(btnc), .clean_out(start));
    debounce deb_reset(.clock_in(clk_100mhz), .noisy_in(btnr), .clean_out(reset));   
    
    //selector integration
    reg[3:0] speed;
    selector select(.clk(clk_65mhz), 
                    .level(sw[1:0]),.start(start),
                    .speed(speed));
    
    //sensor integration
    wire[5:0] test_sensors;
    sensor s(.clk(clk_65mhz), .jb_sensors(jb[5:0]),.test_sensors(test_sensors));
    assign led[5:0] = test_sensors;
    
    //visual integration
    wire phsync,pvsync,pblank;
    wire[11:0] visual_pixels;
    visual v(.clk(clk_65mhz),.pvsync(pvsync),.phsync(phsync),
            .ready_start(start),.speed(speed),
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
    
    // audio integration 
    top_level_audio audio(.clk(clk_100mhz), .clk_25mhz(clk_25mhz), .start(start), .reset(reset), .sd_cd(sd_cd), // start from selector?
                            .selection(sw[1:0]), .sd_dat(sd_dat), .sd_reset(sd_reset), .sd_sck(sd_sck),
                            .sd_cmd(sd_cmd), .aud_sd(aud_sd), .aud_pwm(aud_pwm));
    // game integration
    logic [31:0] game_score;
    top_level_game game(.clk(clk_100mhz), .reset(reset), .start(start), .ca(ca), .cb(cb), .cc(cc), .cd(cd), .ce(ce), .cf(cf), .cg(cg), .an(an));
                            
    
    
endmodule
