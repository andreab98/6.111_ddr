`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 12/05/2019 03:49:51 PM
// Design Name: 
// Module Name: score_blob_1
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


module score_blob_1
    #(parameter WIDTH = 48,     // default picture width
               HEIGHT = 48,
               HCOUNT_LATENCY =4)    // default picture height
   (input pixel_clk_in,
    input [10:0] x_in,hcount_in,
    input [9:0] y_in,vcount_in,
    input [4:0] num,
    
   output logic [11:0] pixel_out);

   logic [15:0] image_addr;   
   logic [7:0] image_bits, red_mapped;
   
   // calculate rom address and read the location
   assign image_addr = ((hcount_in + HCOUNT_LATENCY) -x_in) + (vcount_in-y_in) * WIDTH + 2304 * num;
   
   score2 score(.clka(pixel_clk_in), .addra(image_addr), .douta(image_bits));

   rgbcm score1 (.clka(pixel_clk_in), .addra(image_bits), .douta(red_mapped));
   
   // note the one clock cycle delay in pixel!
   always @ (posedge pixel_clk_in) begin
     if (((hcount_in >= x_in && hcount_in < (x_in+WIDTH)) && (vcount_in >= y_in && vcount_in < (y_in+HEIGHT))))
        // use MSB 4 bits
        pixel_out <= ~{red_mapped[7:4], red_mapped[7:4], red_mapped[7:4]};
        else pixel_out <= 0;
   end

endmodule
