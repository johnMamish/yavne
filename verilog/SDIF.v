module SDIF(input wire clock,
            input wire reset,
            input wire [31:0] in_addr,
            input wire begin_read,
            

            output wire valid_read,
            output wire [7:0] sd_byte,
            input wire miso,
            output reg ss,              
            output wire sclk,
            output wire mosi
);

        reg [4:0] state, next_state; 
        reg [9:0] cv, ncv;
        reg [7:0] com, next_com;
        reg [31:0] addr, next_addr;
        wire [7:0] rbw, ib_in;
        reg [7:0] rb;
        reg next_ss;
        reg ib_v, next_ib_v;
        wire byte_ready;
        reg spir; 
        assign valid_read = (state == state_read3);
        assign sd_byte = valid_read ? rb : 0;

        assign ib_in = (cv == 10'd0) ? com :
                       (cv == 10'd1) ? addr[31:24] :
                       (cv == 10'd2) ? addr[23:16] :
                       (cv == 10'd3) ? addr[15:8]  :
                       (cv == 10'd4) ? addr[7:0]   :
                       (cv == 10'd5) ? crc         :
                       8'hFF;




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

        
         parameter crc   = 8'h95;
         parameter com_reset = 8'h40;
         parameter com_init  = 8'h41;
         parameter com_read  = 8'h51;




        always @(posedge clock) begin
            if (reset) begin
                ss   <= 1'b1;
                addr <= 32'd0;
                com  <= com_reset;
                state <= state_reset0;
                ib_v  <= 1;
            end else begin
                ss <= next_ss;
                addr <= next_addr;
                cv <= ncv;
                state <= next_state;
                com <= next_com;
                ib_v <= next_ib_v;
                if (byte_ready)
                    rb <= rbw;
            end
        end

        always @* begin
            next_addr = addr;
            next_state = state;
            ncv = cv;
            next_ss = ss;
            spir = 1'b0;
            next_com = com;
            if(byte_ready) 
               ncv = cv + 1; 
            

            case(state) 
                state_reset0: begin
                    if (cv == 10) begin
                        next_state = state_reset1;
                        next_ib_v = 0;
                        next_ss = 1; 
                    end
                end

                state_reset1: begin
                    next_state = state_reset2;
                    next_ib_v = 1;
                    ncv = 0;
                    spir = 1;
                    next_com = com_reset;
                end
                
                state_reset2: begin
                    if ( cv > 6 && rb == 8'd1) begin
                        next_ss = 1;
                        ncv = 7;
                        spir = 1;
                        next_state = state_reset3;
                    end
                end

                state_reset3: begin
                    if ( cv >= 8) begin
                        next_ss = 0;
                        ncv = 0;
                        spir = 1;
                        next_com = com_init;
                        next_state = state_reset4;
                    end
                   
                end

                state_reset4: begin
                    if ( cv > 6 && cv < 16 && rb == 0) begin
                        next_state = state_idle;
                        spir = 1;
                        ncv = 0; 
                        next_ss = 1;
                        next_ib_v = 0;
                    end else if (cv >= 16) begin
                        next_state = state_reset3;
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
