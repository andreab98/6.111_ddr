`timescale 1ns / 1ps

module top_level(
   input clk_100mhz,
   input btnc, // start signal
   input btnr, // system reset
   input btnl, // system pause]
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
    //clk_wiz_0 make_clocks(.clk_in1(clk_100mhz),.reset(0), .clk_out1(clk_25mhz), .clk_out2(clk_100mhz_out), .clk_out3(clk_65mhz));
    final_clock_wizard clocks(.clk_in1(clk_100mhz),.reset(0), .clk_out1(clk_100mhz_out), .clk_out2(clk_65mhz), .clk_out3(clk_25mhz));
    
    logic reset; 
    logic start;
    logic pause;
    
    //debounce button inputs 
    debounce deb_start(.clock_in(clk_100mhz), .noisy_in(btnc), .clean_out(start));
    debounce deb_reset(.clock_in(clk_100mhz), .noisy_in(btnr), .clean_out(reset));   
    debounce deb_pause(.clock_in(clk_100mhz), .noisy_in(btnl), .clean_out(pause));   

    
    //xvga for selector and visual modules
    wire [10:0] hcount;    // pixel on current line
    wire [9:0] vcount;     // line number
    wire hsync, vsync;
    logic blank;
    xvga xvga1(.vclock_in(clk_65mhz),.hcount_out(hcount),.vcount_out(vcount),
          .hsync_out(hsync),.vsync_out(vsync),.blank_out(blank));
    
    //selector integration
    reg[4:0] speed;
    wire [11:0] menu_pixels;
    wire phsync_m,pvsync_m,pblank_m;
    //reg [1:0] level = sw[1:0];
    
    logic game_ready;
    wire[11:0] max_num;
    selector select(.clk(clk_65mhz), .hcount(hcount),.vcount(vcount),
                    .hsync(hsync), .vsync(vsync), .blank(blank),
                    .level(sw[1:0]),.start(start),.game_ready(game_ready),.reset(reset),
                    .speed(speed),.menu_pixels(menu_pixels),.max_steps(max_num),
                    .phsync_out(phsync_m),.pvsync_out(pvsync_m),.pblank_out(pblank_m));
    
    //sensor integration
    wire[5:0] test_sensors;
    wire[4:0] out_data;
    // test with switches:
    //sensor s(.clk(clk_65mhz), .jb_sensors(sw[15:10]),.test_sensors(test_sensors), .out_data(out_data));

    sensor s(.clk(clk_65mhz), .jb_sensors(jb[5:0]),.test_sensors(test_sensors), .out_data(out_data));
    assign led[5:0] = test_sensors;
    
    
    // game integration
    logic [31:0] game_score;
    wire correct;
    wire ready_in;
    wire game_over;
    wire score_ready;
    wire perfect;
    wire streak; 
    wire[4:0] correct_data;
    top_level_game game(.clk(clk_65mhz), .reset(reset), .start(start), 
                        .score(game_score), .sensor_data(out_data), .correct_data(correct_data),
                        .perfect_check(perfect),.streak(streak),
                        .game_over(game_over),.ready_in(ready_in), .correct(correct));
    
    //visual integration
    wire phsync_vis,pvsync_vis,pblank_vis;
    wire[11:0] visual_pixels;
    visual v(.clk(clk_65mhz), .pvsync(pvsync_vis), .phsync(phsync_vis), .pblank(pblank_vis),
            .ready_start(game_ready), .speed(speed), .sensor_data(out_data),.start(start),
            .reset(reset), .pause(pause), .game_over(game_over), .score(game_score),
            .correct_data(correct_data), .ready_in(ready_in), .correct(correct), .perfect(perfect), .streak(streak),
            .vcount(vcount), .hcount(hcount), .hsync(hsync), .vsync(vsync), .blank(blank),
            .arrow_pixels(visual_pixels),.max_num(max_num));
            
    //ila_0 ila (.clk(clk_65mhz), .probe0(0), .probe1(out_data[4:0]),.probe2(correct_data[4:0]),.probe3(ready_in),
     //           .probe4(correct),.probe5(perfect), .probe6(0), .probe7(0));
            
    reg b,hs,vs;
    reg [11:0] rgb;
    always_ff @(posedge clk_65mhz) begin
         if (game_ready) begin 
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
    

    // audio integration 
    top_level_audio audio(.clk(clk_100mhz), .clk_25mhz(clk_25mhz), .start(start), .pause(pause), .reset(reset), .sd_cd(sd_cd), // start from selector?
                            .selection(sw[1:0]), .sd_dat(sd_dat), .sd_reset(sd_reset), .sd_sck(sd_sck),
                            .sd_cmd(sd_cmd), .aud_sd(aud_sd), .aud_pwm(aud_pwm));
                            
    assign data_display = game_score; 
    
endmodule
