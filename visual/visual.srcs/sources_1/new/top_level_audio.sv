`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 11/19/2019 02:12:01 PM
// Design Name: 
// Module Name: top_level_audio
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


module top_level_audio(input clk_100mhz,
                       input btnc, 
                       input btnr,
                       input sd_cd,
                       input [2:0] sw,
                       
                       inout [3:0] sd_dat,
                       
                       output logic [15:0] led,
                       output logic sd_reset, 
                       output logic sd_sck, 
                       output logic sd_cmd,
                       output logic aud_sd, 
                       output logic aud_pwm
    );
    
    // debounce buttons 
    logic reset; 
    logic start;
   
    debounce deb_start(.clock_in(clk_100mhz), .noisy_in(btnc), .clean_out(start));
    debounce deb_reset(.clock_in(clk_100mhz), .noisy_in(btnr), .clean_out(reset));
    
    // must read from SD card on 25MHz clock
    logic clk_25mhz;
    clk_wiz_0 sd_clock(.clk_in1(clk_100mhz), .clk_out1(clk_25mhz));
   
    
    // assign set outputs 
    assign aud_sd = 1; 
    assign sd_dat[2] = 1;
    assign sd_dat[1] = 1; 
    assign sd_reset = 0;
    
    // set initial address based on selected song 
    logic [31:0] addr_0;
    parameter MORE_START_ADDR = 32'd0; // More by Usher
    parameter WAVING_START_ADDR = 32'hE53000; // Waving Through a Window 
    
    always_comb begin
        if (sw[2:0] == 3'b000) begin 
            addr_0 = MORE_START_ADDR;
        end 
        else if (sw[2:0] == 3'b001) begin 
            addr_0 = WAVING_START_ADDR;
        end 
    end 
    
    // logic for read operations
    logic ready;
    logic [31:0] addr = addr_0;
    logic rd; 
    logic [7:0] dout; 
    logic byte_available;
    
    logic last_byte_available; //use to find positive edge of byte_available signal
    
    // logic for write operation -- set to 0
    logic wr = 0;
    logic [7:0] din = 0; 
    logic ready_for_next_byte = 0;
    
    // handles reading from the SD card
    sd_controller sd(.reset(reset), .clk(clk_25mhz), .cs(sd_dat[3]), .mosi(sd_cmd), 
                     .miso(sd_dat[0]), .sclk(sd_sck), .ready(ready), .address(addr),
                     .rd(rd), .dout(dout), .byte_available(byte_available),
                     .wr(wr), .din(din), .ready_for_next_byte(ready_for_next_byte)); 
                     
    // logic for FIFO 
    logic [7:0] data_to_fifo = dout; // data from the SD card
    logic [7:0] data_from_fifo; // data to PWM
    logic fifo_wr_en; // fifo write enable
    logic fifo_rd_en; // fifo read enable 
    logic [15:0] data_count; 
    logic fifo_full;
    logic fifo_empty;
    
    // FIFO - handles asynchonous inputs and outputs   
    fifo_generator_0 fifo(.full(fifo_full), .empty(fifo_empty), .din(data_to_fifo), .dout(data_from_fifo), 
                          .wr_en(fifo_wr_en), .rd_en(fifo_rd_en), .clk(clk_100mhz), .srst(reset), .data_count(data_count));
                           
    // states
    parameter IDLE = 2'b01; // Game not in play
    parameter READ = 2'b10; // Game in play
    logic [1:0] state = IDLE; 
    
    // count bytes read during one SD read operation
    logic [9:0] bytes_from_fifo = 0; 
    parameter COMPLETE_READ = 511; // each operation reads 512 bytes
    
    // want to send byte from FIFO every 64khz
    logic [15:0] fifo_count = 0;
    parameter FIFO_READ = 1561; // read every 1561 cycles 
    
    // keep track of the total bytes samples - dictates when to stop playing the song
    logic [23:0] sample_counter = 0;
    parameter MORE_SAMPLES = 14016000;
    parameter WAVING_SAMPLES = 14660128;
    
    always_ff @(posedge clk_100mhz) begin
        //system reset
        if (reset) begin 
            state <= IDLE; 
            
            // reset counters 
            bytes_from_fifo <= 0;
            fifo_count <= 0;    
            sample_counter <= 0;
            
            // reset pulses 
            fifo_rd_en <= 0;
            fifo_wr_en <= 0;
            rd <= 0;
            
        end 
        case(state) 
            IDLE: begin 
                if (start) begin //game begins 
                    addr <= addr_0;
                    state <= READ; 
                    rd <= 1; //might not need this?
                end                 
            end 
            READ: begin
                if ((sw[2:0] == 3'b000 && sample_counter >= MORE_SAMPLES) 
                     || (sw[2:0] == 3'b001 && sample_counter >= WAVING_SAMPLES)) begin // when the song is over... game also over
                     
                    led[15] <= 1;
                    
                    //reset counters
                    sample_counter <= 0; 
                    bytes_from_fifo <= 0;
                    fifo_count <= 0;
                    
                    //reset pulses
                    fifo_rd_en <= 0;
                    fifo_wr_en <= 0;
                    rd <= 0;
                    
                    state <= IDLE; 
                    
                end else begin
                
                    last_byte_available <= byte_available; //to detect rising edge of byte_available
                    
                    if (data_count <= 8192) begin  
                        rd <= 1;
                    end else begin 
                        rd <= 0;
                    end 
                    
                    // once we read 512 bytes from the FIFO, increment address and start reading again
                    if (bytes_from_fifo >= COMPLETE_READ) begin //this works 
                        addr <= addr + 32'h200; // increment by multiple of 512 bytes
                        bytes_from_fifo <= 0;
                    end 
                    
                    // write to the FIFO when there is a byte available on dout 
                    if ((byte_available == 1 && last_byte_available == 0) && fifo_full != 1) begin // check for rising edge of byte_available
                        fifo_wr_en <= 1; 
                    end else begin 
                        fifo_wr_en <= 0;
                    end 
                    
                    // enable fifo read every 3124 cycles
                    if (fifo_count >= FIFO_READ && fifo_empty != 1) begin     
                        fifo_count <= 0;
                        
                        // keep track of bytes read from FIFO
                        bytes_from_fifo <= bytes_from_fifo + 1; // to keep track of complete reads
                        sample_counter <= sample_counter + 1; // total samples 
                        fifo_rd_en <= 1; 
                    
                    end else begin
                        fifo_rd_en <= 0; 
                        fifo_count <= fifo_count + 1;
                    end 
                end
            end
        endcase
        
    end 
    
    logic sound_out;
    audio_PWM pwm(.clk(clk_100mhz), .reset(reset), .music_data(data_from_fifo), .PWM_out(aud_pwm));
    
endmodule