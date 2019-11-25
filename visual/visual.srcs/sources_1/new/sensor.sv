`timescale 1ns / 1ps
module sensor(
        input clk,
        input[5:0] jb_sensors,
        
        output[5:0] test_sensors
//        output ca, cb, cc, cd, ce, cf, cg,
//        output[7:0] an    
    );

    // debounce all sensor inputs 
    wire clean_0;
    debounce d0 (.clock_in(clk), .noisy_in(jb_sensors[0]), .clean_out(clean_0));
    wire clean_1;
    debounce d1 (.clock_in(clk), .noisy_in(jb_sensors[1]), .clean_out(clean_1));
    wire clean_2;
    debounce d2 (.clock_in(clk), .noisy_in(jb_sensors[2]), .clean_out(clean_2));
    wire clean_3;
    debounce d3 (.clock_in(clk), .noisy_in(jb_sensors[3]), .clean_out(clean_3));
    wire clean_4;
    debounce d4 (.clock_in(clk), .noisy_in(jb_sensors[4]), .clean_out(clean_4));   
    wire clean_5;
    debounce d5 (.clock_in(clk), .noisy_in(jb_sensors[5]), .clean_out(clean_5));
    
    assign test_sensors = {clean_0, clean_1,clean_2,clean_3,clean_4,clean_5};
    
    reg[8:0] out_data;
    overlap o(.clk(clk), .clean_0(clean_0),.clean_1(clean_1), .clean_2(clean_2),
                .clean_3(clean_3), .clean_4(clean_4), .clean_5(clean_5),
                .intersection_data(out_data));
    
//    wire [31:0] data_display;      //  instantiate 7-segment display; display (8) 4-bit hex
//    wire [6:0] segments;
//    assign {cg, cf, ce, cd, cc, cb, ca} = segments[6:0];
//    display_8hex display(.clk_in(clk),.data_in(data_display), .seg_out(segments), .strobe_out(an));
    

//    assign data_display = {3'b00,out_data[8],
//                            3'b00,out_data[7],
//                            3'b00,out_data[6],
//                            3'b00,out_data[5],
//                            3'b00,out_data[3],
//                            3'b00,out_data[2],
//                            3'b00,out_data[1],
//                            3'b00,out_data[0]}; 

endmodule
