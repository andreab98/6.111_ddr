`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// loading_blob: comes up before the game starts to load the music
//////////////////////////////////////////////////////////////////////////////////


module loading_blob
 #(parameter WIDTH = 395,     // default picture width
               HEIGHT = 77,
               HCOUNT_LATENCY = 4)    // default picture height
   (    input pixel_clk_in,
        input [10:0] x_in,hcount_in,
        input [9:0] y_in,vcount_in,
        input on, // determined whether or not to show the image
    
        output logic [11:0] pixel_out
    );
    
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
