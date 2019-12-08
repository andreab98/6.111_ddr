`timescale 1ns / 1ps
// Audio PWM module.

//module audio_PWM(
//    input clk, 			// 100MHz clock.
//    input reset,		// Reset assertion.
//    input [7:0] music_data,	// 8-bit music sample
//    output reg PWM_out		// PWM output. Connect this to ampPWM.
//    );
    
    
//    reg [7:0] pwm_counter = 8'd0;           // counts up to 255 clock cycles per pwm period
       
          
//    always @(posedge clk) begin
//        if(reset) begin
//            pwm_counter <= 0;
//            PWM_out <= 0;
//        end
//        else begin
//            pwm_counter <= pwm_counter + 1;
            
//            if(pwm_counter >= music_data) PWM_out <= 0;
//            else PWM_out <= 1;
//        end
//    end
//endmodule

module audio_PWM (input clk_in, input rst_in, input [7:0] level_in, output logic pwm_out);
    logic [7:0] count, ramp;
    logic flip;

//    assign pwm_out = count<level_in;
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

