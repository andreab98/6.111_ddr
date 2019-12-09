`timescale 1ns / 1ps

////////////////////////////////////////////////////
//
// menu_blob: display the menu
//
//////////////////////////////////////////////////
module menu_blob
   #(parameter WIDTH = 400,     // default picture width
               HEIGHT = 275,
               HCOUNT_LATENCY = 4)    // default picture height
   (input pixel_clk_in,
    input [10:0] x_in, hcount_in,
    input [9:0] y_in, vcount_in,
    output logic [11:0] pixel_out);
    
   logic [19:0] image_addr;   
   logic [7:0] image_bits, red_mapped;
   
   // calculate rom address and read the location
   assign image_addr = ((hcount_in + HCOUNT_LATENCY)-x_in) + (vcount_in-y_in) * WIDTH;
   
   ddr_menu m(.clka(pixel_clk_in), .addra(image_addr), .douta(image_bits));
   ddr_color_map ddr_map(.clka(pixel_clk_in), .addra(image_bits), .douta(red_mapped));
   
   // note the one clock cycle delay in pixel!
   always @ (posedge pixel_clk_in) begin
     if (((hcount_in >= x_in && hcount_in < (x_in+WIDTH)) && (vcount_in >= y_in && vcount_in < (y_in+HEIGHT))))
        pixel_out <= ~{red_mapped[7:4], red_mapped[7:4], red_mapped[7:4]}; // greyscale
        else pixel_out <= 0;
   end
endmodule