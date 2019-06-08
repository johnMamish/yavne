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
                output reg [9:0] rd_addr,
                output wire [7:0] vga_data
                );

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
    reg [9:0] rd_addr_next;
    reg [9:0] x_addr_prev, y_addr_prev;
    wire [9:0] mod_addr;
    wire wren;
    assign mod_addr = addr[10:0] - 10'h200;
    
    assign wren = (addr[15:0] >= 16'h200) && (addr[15:0] < 16'h600) && ~rw;

	 wire [9:0] comb_addr = {4'b0, x_addr[9:4]} + {y_addr[9:4], 5'b0};
	 
    always @* begin
        rd_addr_next = rd_addr;
        if (y_addr_prev != y_addr && (y_addr == 10'd0) )
            rd_addr_next = 0;
        else if(x_addr_prev != x_addr && (x_addr & 10'h1f) == 10'd20) 
            rd_addr_next = rd_addr + 1'b1;
        else if (x_addr_prev != x_addr && (x_addr == 10'd0) )
            rd_addr_next = rd_addr - 10'd31;
        else if (y_addr_prev != y_addr && (y_addr & 10'hf) == 10'd15) 
            rd_addr_next = rd_addr + 10'd1;
    end


 
    vga_ram screen_memory(.address_a(comb_addr),
                          .address_b(mod_addr),
                          .clock(CLOCK_50),
                          .data_a(0),
                          .data_b(data),
                          .wren_a(1'b0), //vga module only reads
                          .wren_b(wren),
                          .q_a(color_decider),
                          .q_b(vga_data));




    
    

    always @(posedge CLOCK_50) begin
        if (reset) begin
            rd_addr <= 0;
            x_addr_prev <= 0;
            y_addr_prev <= 0; 
           
        end else begin
            rd_addr <= rd_addr_next;
            x_addr_prev <= x_addr;
            y_addr_prev <= y_addr; 
            
        end
    end
  


    wire [9:0] x_addr, y_addr, vga_r, vga_g, vga_b;


 
    assign vga_r =  color_decider != 0 ? 10'h3ff : 0;
    assign vga_g =  color_decider != 0 ? 10'h3ff : 0;
                   
    assign vga_b =  color_decider != 0 ? 10'h3ff : 0;
endmodule
