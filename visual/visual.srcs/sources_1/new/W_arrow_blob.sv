`timescale 1ns / 1ps

////////////////////////////////////////////////////
//
// W_arrow_blob: display a picture of the west arrow 
//
//////////////////////////////////////////////////
module W_arrow_blob
   #(parameter WIDTH = 113,     // default picture width
               HEIGHT = 113,    // default picture height 
               HCOUNT_LATENCY = 4)  // counts the number of hundreds, tens, and ones places in a 10 bit number 
   (input pixel_clk_in,
    input [10:0] x_in,hcount_in,
    input [9:0] y_in,vcount_in,
    input on,
    output logic [11:0] pixel_out);

   logic [15:0] image_addr;   
   logic [7:0] image_bits, red_mapped;
   
   // calculate rom address and read the location
   assign image_addr = ((hcount_in + HCOUNT_LATENCY)-x_in) + (vcount_in-y_in) * WIDTH;
   
   west_arrow  west(.clka(pixel_clk_in), .addra(image_addr), .douta(image_bits));

   blk_mem_gen_0 rcm (.clka(pixel_clk_in), .addra(image_bits), .douta(red_mapped));
   
   // note the one clock cycle delay in pixel!
   always @ (posedge pixel_clk_in) begin
     if (on&&((hcount_in >= x_in && hcount_in < (x_in+WIDTH)) && (vcount_in >= y_in && vcount_in < (y_in+HEIGHT))))
        pixel_out <= {red_mapped[7:4], red_mapped[7:4], red_mapped[7:4]}; // greyscale
        else pixel_out <= 0;
   end
endmodule