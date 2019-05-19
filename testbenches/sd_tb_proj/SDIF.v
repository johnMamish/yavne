module SDIF(input wire clock,
            input wire reset,
            input wire [31:0] in_addr,
            input wire begin_read,
                
            output wire idle,
            output wire valid_read,
            output wire [7:0] sd_byte,


            input wire miso,
            output reg ss,              
            output wire sclk,
            output wire mosi, 
            output reg [4:0] state,
            output reg [5:0] crc_counter,
            output wire[7:0] crc

);



        reg [6:0] crc_reg, next_crc_reg;
        reg [4:0] next_pts, pts, next_state;
        reg [9:0] cv, ncv;
        reg [7:0] com, next_com;
        reg [7:0] next_crc_counter;
        reg [31:0] addr, next_addr;
        wire [7:0] rbw, ib_in;
        reg [7:0] rb;
        wire [46:0] serialized_packet;
        assign serialized_packet = {com, addr, 7'd0};
        assign crc = {crc_reg, 1'b1};
          
        reg next_ss;
        reg ib_v,next_ib_v;
        wire byte_ready;
        reg spir; 
        assign valid_read = (state == state_read3);
        assign sd_byte = valid_read ? rb : 0;
        assign idle = (state == state_idle);
          
        assign ib_in = (cv == 10'd0) ? com :
                       (cv == 10'd1) ? addr[31:24] :
                       (cv == 10'd2) ? addr[23:16] :
                       (cv == 10'd3) ? addr[15:8]  :
                       (cv == 10'd4) ? addr[7:0]   :
                       (cv == 10'd5) ? crc         :
                       8'h00;




        SPIbs spiface(.clock(clock),
                      .reset(spir), 
                      .ib_v(ib_v),
                      .ib_in(ib_in),
                      .rb_o(rbw),
                      .byte_ready(byte_ready),
                      .sclk(sclk),
                      .mosi(mosi), 
                      .miso(miso));
                    
        //SD Card packet is as follows:
        /* WRITE:
         * Byte of CMD
         * 4 BYTES ADDR (MSB first)
         * static byte 0x95
         *
         * read for up to 8 cycles after 
         */

         parameter state_reset0 = 5'd0;
         parameter state_reset1 = 5'd1;
         parameter state_reset2 = 5'd2;
         parameter state_reset3 = 5'd3;
         parameter state_reset4 = 5'd4;
         parameter state_reset5 = 5'd5;
         parameter state_idle   = 5'd6;
         parameter state_read0  = 5'd7;
         parameter state_read1  = 5'd8;
         parameter state_read2  = 5'd9;
         parameter state_read3  = 5'd10;
         parameter state_read4  = 5'd11;
         parameter state_fail   = 5'd12;
         parameter state_compute_crc = 5'd13;
         parameter state_reset6 = 5'd14;
         parameter state_reset7 = 5'd15;
         parameter state_reset8 = 5'd16;

         parameter com_reset = 8'd0;
         parameter com_vc      = 8'd8;
         parameter com_init  = 8'd1;
         parameter com_read  = 8'd17;
         parameter com_55 = 8'd55;
         parameter com_41 = 8'd41;




        always @(posedge clock) begin
            if (reset) begin
                ss   <= 1'b1;
                addr <= 32'd0;
                com  <= 8'h40 | com_reset;
                state <= state_reset0;
                ib_v  <= 1;
                crc_counter <= 0;
                crc_reg <= 7'h7a;
                pts <= state_reset1;
            end else begin
                ss          <= next_ss;
                addr        <= next_addr;
                cv          <= ncv;
                state     	 <= next_state;
                com         <= 8'h40 | next_com;
                ib_v     	 <= next_ib_v;
                     crc_counter <= crc_counter + 1'b1;
                     crc_reg <= next_crc_reg;
                     pts            <= next_pts;
                if (byte_ready)
                    rb <= rbw;
                     
                     if (next_state == state_compute_crc && state != state_compute_crc) begin
                        crc_counter <= 0;
                        crc_reg     <= 7'h0;
                     end
            end
        end

        always @* begin
            next_addr = addr;
            next_state = state;
            ncv = cv;
            next_ss = ss;
            spir = reset;
            next_com = com;
                next_ib_v = ib_v;
                next_pts = pts;
                next_crc_reg = crc_reg;
                next_crc_counter = crc_counter;
            if(byte_ready) 
               ncv = cv + 1; 
            

            case(state) 
                
                    state_compute_crc: begin
                        if (crc_counter < 6'd47) begin
                            //this is definitely inferring a mux here, but its fine
                            next_crc_counter = crc_counter + 1'b1;
                            next_crc_reg = {crc_reg[5:0], serialized_packet[6'd46 -crc_counter]} ^ (crc_reg[6] ? 7'h09 : 7'd0); 
                        end
                        else begin
                            next_state = pts;
                        end                    
                    end 
                
                
                state_reset0: begin
                    if (cv == 10) begin
                        next_state = state_compute_crc;
                        next_ib_v = 0;
                        next_ss = 1;
                                next_com = com_reset;
                                next_pts = state_reset1;
                    end
                end

                     
                     
                     
                state_reset1: begin
                   next_ss = (crc_counter == 0) ? 0 : 1'b1;
                    ncv = 0;
                    spir = 1'b1;
						  next_ib_v = (crc_counter == 0) ? 1'b1 : 1'b0;
                    next_state = (crc_counter == 0) ? state_reset2 : state_reset1;
                end
                
                state_reset2: begin
                    if ( cv > 6 && rb == 8'd1) begin
                        next_ss = 1;
                        ncv = 7;
                        spir = 1;
                        next_state = state_compute_crc;
                        next_pts = state_reset3;
                        next_addr = 32'h000001aa;
                        next_com = com_vc;
                    end else if (cv > 20) begin
                         next_state = state_reset1;
                      end
                                
                end

                state_reset3: begin 
                    next_ss = (crc_counter == 0) ? 0 : 1'b1;
                    ncv = 0;
                    spir = 1'b1;
					next_ib_v = (crc_counter == 0) ? 1'b1 : 1'b0;
                    next_state = (crc_counter == 0) ? state_reset4 : state_reset3;
                end

                state_reset4: begin
                    if ( cv > 6 && cv < 16 && rb == 8'd1) begin
                        next_state = state_reset5;
                        spir = 1;
                        ncv = 0; 
                        next_ss = 1;
                        next_ib_v = 0; 
                        next_addr = 0;
                    end else if (cv >= 16) begin
                        next_state = state_reset3;
                        next_ss = 1'b1;
                        spir = 1'b1;
                    end
                end

                state_reset5: begin
                    next_com = com_55;
                    next_ss = (crc_counter == 0) ? 0 : 1'b1;
                    ncv = 0;
                    spir = 1'b1;
                    next_ib_v = (crc_counter == 0) ? 1'b1 : 1'b0;
                    next_state = (crc_counter == 0) ? state_reset6 : state_reset5;
                end


                state_reset6: begin
                    if ( cv > 6 && cv < 16 && (rb == 8'd1 || rb == 8'd5)) begin
                        next_state = state_reset7;
                        spir = 1;
                        ncv = 0; 
                        next_ss = 1;
                        next_ib_v = 1;
                        next_com = (rb == 8'd1) ? com_41 : com_init;
                        next_addr = (rb == 8'd1) ? 32'h40000000 : 0;
                    end else if (cv >= 16) begin
                        next_state = state_reset5;
                        next_ss = 1'b1;
                        spir = 1'b1;
                    end
                end

                state_reset7: begin
                    next_ss = (crc_counter == 0) ? 0 : 1'b1;
                    ncv = 0;
                    spir = 1'b1;
                    next_ib_v = (crc_counter == 0) ? 1'b1 : 1'b0;
                    next_state = (crc_counter == 0) ? state_reset8 : state_reset7;
                end

                
                state_reset8: begin
                    if ( cv > 6 && cv < 16 && (rb == 8'd0 || rb == 8'd5)) begin
                        next_state = (rb == 8'd0) ? state_idle : state_reset7;
                        spir = 1;
                        ncv = 0; 
                        next_ss = 1;
                        next_ib_v = 1;
                        next_com = (rb == 8'd0) ? com_41 : com_init;
                        next_addr = 0; 
                    end else if (cv >= 16) begin
                        next_state = state_reset5;
                        next_ss = 1'b1;
                        spir = 1'b1;
                    end
                end


                state_idle: begin
                    spir = 1;
                    ncv = 0;
                    next_ss = 1;
                    next_ib_v = 0;
                    if( begin_read) begin
                        next_addr  = in_addr;
                        next_ss = 0;
                        next_ib_v = 1;
                        next_state = state_read0;
                        next_com   = com_read;
                    end
                end 

                state_read0: begin
                    if ( cv > 6 && cv < 16 && rb == 0) begin
                        next_state = state_read1;
                        ncv = 10;
                        spir = 1;
                    end else if ( cv >= 16) begin
                        next_state = state_fail;
                    end
                end

                state_read1: begin
                    if( ncv == 0) 
                        ncv = 10;
                    if ( rb == 8'hFE) begin
                        next_state = state_read2;
                        spir = 1;
                        ncv = 10;
                    end
                end
                
                state_read2: begin
                    if(ncv == 11)
                        next_state = state_read3;
                 end

                state_read3: begin
                    if(cv > 10'd521) begin
                        next_state = state_read4;
                        ncv = 10;
                    end
                end

                state_read4: begin
                    if (cv == 12) begin
                        next_state= state_idle;
                        spir = 1;
                        next_ss = 1;
                        next_ib_v = 0;
                    end
                end
                
                state_fail: begin
                    next_state = state_fail;
                end
                default:
                    next_state = state_fail;

            endcase
        end


endmodule
