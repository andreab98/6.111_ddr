`timescale 1ns / 1ps
module sensor(
        input clk,
        input[5:0] jb_sensors,
        
        output[5:0] test_sensors,
        output logic[8:0] out_data
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
    
    overlap o(.clk(clk), .clean_0(clean_0),.clean_1(clean_1), .clean_2(clean_2),
                .clean_3(clean_3), .clean_4(clean_4), .clean_5(clean_5),
                .intersection_data(out_data));

endmodule
