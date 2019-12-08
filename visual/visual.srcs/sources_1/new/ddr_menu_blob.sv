`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 12/07/2019 03:46:07 PM
// Design Name: 
// Module Name: ddr_menu_blob
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


module ddr_menu_blob
   #(parameter WIDTH = 400,     // default picture width
               HEIGHT = 275)    // default picture height
   (input pixel_clk_in,
    input [10:0] x_in,hcount_in,
    input [9:0] y_in,vcount_in,
    output logic [11:0] pixel_out);
    
   logic [19:0] image_addr;   
   logic [7:0] image_bits, red_mapped;
   
   // calculate rom address and read the location
   assign image_addr = (hcount_in-x_in) + (vcount_in-y_in) * WIDTH;
   
   ddr_menu m(.clka(pixel_clk_in), .addra(image_addr), .douta(image_bits));

   rgbcm score1 (.clka(pixel_clk_in), .addra(image_bits), .douta(red_mapped));
   
   // note the one clock cycle delay in pixel!
   always @ (posedge pixel_clk_in) begin
     if (((hcount_in >= x_in && hcount_in < (x_in+WIDTH)) && (vcount_in >= y_in && vcount_in < (y_in+HEIGHT))))begin
       pixel_out <= ~{red_mapped[7:4], red_mapped[7:4], red_mapped[7:4]}; // greyscale
     end else begin
        pixel_out <= 0;
     end 
   end
endmodule

