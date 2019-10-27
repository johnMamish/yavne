module  mmio_vga(
                input CLOCK_50,
                input reset,
                input clock, 
                input [15:0] addr,
                input [7:0] data,
                //write is active low
                input rw, 

                output wire [9:0] VGA_R,
                output wire [9:0] VGA_B,
                output wire [9:0] VGA_G,
                output wire  VGA_CLK,
                output wire  VGA_BLANK, 
                output wire  VGA_HS,
                output wire  VGA_VS,
                output wire  VGA_SYNC, 
                output wire [7:0] vga_data
                );


    vga_ram screen_memory(.address_a(hacky_rd_addr),
                          .address_b(mod_addr[9:0]),
                          .clock(CLOCK_50),
                          .data_a(0),
                          .data_b(data),
                          .wren_a(1'b0), //vga module only reads
                          .wren_b(wren),
                          .q_a(color_decider),
                          .q_b(vga_data));

    wire 


    vga vga_driver(.clock(CLOCK_50),
            .reset(reset),
            .vga_r(vga_r),
            .vga_g(vga_g),
            .vga_b(vga_b),
            .vga_r_DAC(VGA_R),
            .vga_g_DAC(VGA_G),
            .vga_b_DAC(VGA_B),
            .x_addr(x_addr),
            .y_addr(y_addr),
            .vga_clock(VGA_CLK),
            .vga_sync_dac(VGA_SYNC),
            .vga_hs(VGA_HS),
            .vga_vs(VGA_VS),
            .vga_blank(VGA_BLANK)); 


    wire [7:0] color_decider;
    reg  [7:0] vga_driver_reg;
	reg  [4:0] x_coord, y_coord, y_coord_n,x_coord_n;
    reg [9:0] rd_addr_next, x_cnt, y_cnt, x_cnt_next, y_cnt_next, rd_addr;
	wire [9:0] comb_addr;
    reg prev_clk; 
	assign comb_addr = (x_addr >> 4) + ((y_addr & 10'h3f0) );
    reg [9:0] x_addr_prev, y_addr_prev;
    wire [10:0] mod_addr;
    wire wren;
    assign mod_addr = addr[10:0] - 10'h200;
    
    assign wren = (addr[15:0] >= 16'h200) && (addr[15:0] < 16'h600) && ~rw && (prev_clk & ~clock);

    always @* begin
        rd_addr_next = rd_addr;
        y_cnt_next = ((y_addr_prev != y_addr) && (y_addr != 10'h3ff )) ? y_cnt + 1'b1 : y_cnt;
        x_cnt_next = ((x_addr_prev != x_addr) && (x_addr != 10'h3ff )) ? x_cnt + 1'b1 : x_cnt;
		x_coord_n = x_coord;
		y_coord_n = y_coord;
        if (x_addr_prev != x_addr && (y_addr == 10'd0 && x_addr == 10'd0) ) begin
	        y_coord_n = 0;
	        x_coord_n = 0;
            y_cnt_next = 0;
	        x_cnt_next = 0;
            rd_addr_next = 0;
        end else if (y_cnt == 'd15) begin
            y_coord_n = y_coord + 1'b1;
			x_coord_n = 0;
            y_cnt_next = 0;
			x_cnt_next = 0;
            rd_addr_next = rd_addr + 'd32;
        end else if(x_cnt == 'd15 && x_addr < 'd480) begin
            x_coord_n = x_coord + 1'b1;
            rd_addr_next = rd_addr + 1'b1; 
            x_cnt_next = 0;
        end else if (x_addr_prev != x_addr && (x_addr == 10'd0 && y_addr != 10'd0) ) begin
            x_coord_n = 0;
            rd_addr_next = rd_addr - 'd31; 
            x_cnt_next = 0;
        end 
        
    end


 


    
    

    always @(posedge CLOCK_50) begin
        if (reset) begin
            rd_addr <= 0;
            x_addr_prev <= 0;
            y_addr_prev <= 0; 
            prev_clk <= 0; 
            x_cnt <= 0;
            y_cnt <= 0; 
			x_coord <= 0;
			y_coord <= 0;
        end else begin
            rd_addr <= rd_addr_next;
            x_addr_prev <= x_addr;
            y_addr_prev <= y_addr; 
            prev_clk <= clock; 
            x_cnt <= x_cnt_next;
            y_cnt <= y_cnt_next;
		    x_coord <= x_coord_n;
		    y_coord <= y_coord_n;
        end
    end
  


    wire [9:0] x_addr, y_addr, vga_r, vga_g, vga_b;


 
    assign vga_r =  x_addr >= 480      ? 0       :
						  color_decider != 0 ? 10'h3ff : 0;
    assign vga_g =  x_addr >= 480      ? 10'h3ff :
						  color_decider != 0 ? 10'h3ff : 0;
                   
    assign vga_b =  x_addr >= 480      ? 0       :
						  color_decider != 0 ? 10'h3ff : 0;
endmodule
