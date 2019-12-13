module timer(clock, start_timer,  value, counting, 
	 expired_pulse, one_hz, count_out);

    input clock, start_timer;
    input [3:0] value;
    output logic counting; 
    output logic expired_pulse; 
    output logic one_hz;
    output logic [3:0] count_out;
    
    //initialize states -- using one-shot encoding
    parameter IDLE = 2'b01; // idle - waiting for start_timer
    parameter DECR = 2'b10; //decrementing

    //constant for cycle count between 1 second events
    parameter CYCLE_COUNT = 65000000;

    //state begins as idle
    logic[1:0] state = IDLE;
    integer i = 0;

    always_ff @(posedge clock) begin
        //increment counter for one hz event 
        i <= i + 1;
        if (one_hz) begin
            one_hz <= ~one_hz; // if one hz event previously, reset
        end
        if (i == CYCLE_COUNT) begin
            one_hz <= 1'b1; // if 3 clock cycles, set one hz event for 4th
            i <= 0;
        end

        case(state)
            // idle -- waiting for start_timer input 
            IDLE: begin
                // clock expires if timer set to 0 initially
                expired_pulse <= start_timer && ((value!=0)?0:1);

                //start timer -- initialize timer w/ given values
                if(start_timer) begin
                   // expired_pulse <= 1'b0;
                    counting <= 1'b1;
                    i <= 1; //reset 1 hz event counter
                    one_hz <= 1'b0;
                    count_out <= value;
                    state <= DECR;
                end
            end

            // state when timer initialized
            DECR: begin
                //clock expires if about to decrement to 0
                expired_pulse <= (count_out <= 1) && (one_hz)?1:0;
                //reset timer if start_timer pressed     
                if(start_timer) begin
                    i<=1;
                    one_hz <= 1'b0;
                    count_out <= value;
                end

                // counter expires..
                 else if (count_out == 0) begin
                     counting <= 1'b0;
                     state <= IDLE;

                end
                else begin
                    // if one hz event, decrement 
                    if (one_hz) begin
                      count_out <= count_out - 4'b0001;

                      // timer about to expire 
                      if (count_out <= 1) begin
                        counting <= 1'b0;
                      end
                    end
                end
            end
            endcase
    end

endmodule

