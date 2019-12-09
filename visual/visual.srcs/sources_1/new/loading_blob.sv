`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 12/08/2019 07:45:55 PM
// Design Name: 
// Module Name: loading_blob
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


module loading_blob
 #(parameter WIDTH = 395,     // default picture width
               HEIGHT = 77,
               HCOUNT_LATENCY = 4)    // default picture height
   (input pixel_clk_in,
    input [10:0] x_in,hcount_in,
    input [9:0] y_in,vcount_in,
    input on,
    output logic [11:0] pixel_out);
    
   logic [19:0] image_addr;   
   logic [7:0] image_bits, load_mapped;
   
   // calculate rom address and read the location
   assign image_addr = ((hcount_in + HCOUNT_LATENCY)-x_in) + (vcount_in-y_in) * WIDTH;
   
   loading_image load(.clka(pixel_clk_in), .addra(image_addr), .douta(image_bits));
   loading_map loading_color(.clka(pixel_clk_in), .addra(image_bits), .douta(load_mapped));
   
   // note the one clock cycle delay in pixel!
   always @ (posedge pixel_clk_in) begin
     if (on&&((hcount_in >= x_in && hcount_in < (x_in+WIDTH)) && (vcount_in >= y_in && vcount_in < (y_in+HEIGHT))))
        pixel_out <= load_mapped; 
        else pixel_out <= 0;
   end
endmodule
