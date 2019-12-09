`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 12/08/2019 08:29:10 PM
// Design Name: 
// Module Name: perfect_bonus_blob
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


module perfect_bonus_blob
 #(parameter WIDTH = 243,     // default picture width
               HEIGHT = 33, 
               HCOUNT_LATENCY = 4)    // default picture height
   (input pixel_clk_in,
    input [10:0] x_in,hcount_in,
    input [9:0] y_in,vcount_in,
    input on,
    
   output logic [11:0] pixel_out);
   
   
   //assign hcount_in = hcount_in + HCOUNT_LATENCY;
   
   logic [15:0] image_addr;   
   logic [7:0] image_bits, green_mapped;
   
   // calculate rom address and read the location
   assign image_addr = ((hcount_in + HCOUNT_LATENCY)-x_in) + (vcount_in-y_in) * WIDTH;
   
   perfect_rom  perfect(.clka(pixel_clk_in), .addra(image_addr), .douta(image_bits));

   perfect_map perfect_color_map(.clka(pixel_clk_in), .addra(image_bits), .douta(green_mapped));
   
   // note the one clock cycle delay in pixel!
   always @ (posedge pixel_clk_in) begin
     if (on&&((hcount_in + HCOUNT_LATENCY >= x_in && hcount_in + HCOUNT_LATENCY < (x_in+WIDTH)) && (vcount_in >= y_in && vcount_in < (y_in+HEIGHT))))
    //if (((hcount_in  >= x_in && hcount_in  < (x_in+WIDTH)) && (vcount_in >= y_in && vcount_in < (y_in+HEIGHT))))
        // use MSB 4 bits
        pixel_out <= {4'd0, green_mapped[7:4], 4'd0}; // red
        else pixel_out <= 0;
   end
endmodule
