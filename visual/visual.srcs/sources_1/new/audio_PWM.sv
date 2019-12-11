`timescale 1ns / 1ps
// Audio PWM module.

module audio_PWM (input clk_in, input rst_in, input [7:0] level_in, output logic pwm_out);
    logic [7:0] count, ramp;
    logic flip;
    
    assign pwm_out = ramp <level_in;


    always_ff @(posedge clk_in)begin
        if (rst_in)begin
            count <= 8'b0;
            flip <=0;
        end else begin
            count <= count+8'b1;
            flip <= (count == 255) ? !flip : flip;
        end
    end

    // this creates a symmetrical ramp for better audio output.
    assign ramp = flip ? count : 255-count;

endmodule

