`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 09/16/2019 03:21:02 PM
// Design Name: 
// Module Name: seven_seg_controller
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module seven_seg_controller(    input[31:0] val_in,
                                input clk_in,
                                input rst_in,
                                output logic [6:0] cat_out,
                                output logic [7:0] an_out
                            );
                            
        logic[7:0]  segment_state;
        logic[31:0] segment_counter;
        logic[3:0] routed_vals;
        logic[6:0] led_out;
        
        binary_to_seven_segment my_converter(.val_in(routed_vals), .led_out(led_out));
        
        assign cat_out = ~led_out;
        assign an_out = ~segment_state;
        
        always_comb begin
            case(segment_state)
                8'b0000_0001:   routed_vals = val_in[3:0];
                8'b0000_0010:   routed_vals = val_in[7:4];
                8'b0000_0100:   routed_vals = val_in[11:8];
                8'b0000_1000:   routed_vals = val_in[15:12];
                8'b0001_0000:   routed_vals = val_in[19:16];
                8'b0010_0000:   routed_vals = val_in[23:20];
                8'b0100_0000:   routed_vals = val_in[27:24];
                8'b1000_0000:   routed_vals = val_in[31:28];
                default:        routed_vals = val_in[3:0];       
            endcase
        end
        
        
        always_ff @(posedge clk_in)begin
            if (rst_in)begin
                segment_state <= 8'b0000_0001;
                segment_counter <= 32'b0;
            end else begin
                if (segment_counter == 32'd100_000)begin
                    segment_counter <= 32'd0;
                    segment_state <= {segment_state[6:0],segment_state[7]}; // rotate segments instead of shift 
                end else begin
                    segment_counter <= segment_counter +1;
                end
            end
        end
        
endmodule //seven_seg_controller

module binary_to_seven_segment(
            val_in,
            led_out
    );
    
    // 4 bit value representing a binary number 
    input [3:0] val_in;
    
    //seven segment LED pattern 
    output logic [6:0] led_out;
    
    //logic here - binary to hex
    always_comb
    begin
        if(val_in == 4'b0000)
        begin
            led_out = 7'b0111111;
        end
        else if(val_in == 4'b0001)
        begin 
            led_out = 7'b0000110;
        end
        else if (val_in == 4'b0010)
        begin
            led_out = 7'b1011011;
        end 
        else if (val_in == 4'b0011)
        begin
            led_out = 7'b1001111;
        end 
        else if (val_in == 4'b0100)
        begin 
            led_out = 7'b1100110;
        end 
        else if (val_in == 4'b0101)
        begin
            led_out = 7'b1101101;
        end
        else if (val_in == 4'b0110)
        begin
            led_out = 7'b1111101;
        end 
        else if (val_in == 4'b0111)
        begin 
            led_out = 7'b0000111;
        end 
        else if (val_in == 4'b1000)
        begin 
            led_out = 7'b1111111;
        end 
        else if (val_in == 4'b1001)
        begin 
            led_out = 7'b1101111;
        end
        else if (val_in == 4'b1010)
        begin 
            led_out = 7'b1110111;
        end
        else if (val_in == 4'b1011)
        begin
            led_out = 7'b1111100;
        end 
        else if (val_in == 4'b1100)
        begin 
            led_out = 7'b0111001;
        end 
        else if (val_in == 4'b1101)
        begin 
            led_out = 7'b1011110;
        end 
        else if (val_in == 4'b1110)
        begin 
            led_out = 7'b1111001;
        end 
        else if (val_in == 4'b1111)
        begin 
            led_out = 7'b1110001;
        end 
     end
    
endmodule
                
        
        
        
                                        
                                
                             
                            
                      
