module  vga_tb(
                input CLOCK_50,
                input [3:0] SW, 
                
                
                
                //outputs ...  

                output [9:0] VGA_R,
                output [9:0] VGA_B,
                output [9:0] VGA_G,
                output  VGA_CLK,
                output  VGA_BLANK, 
                output  VGA_HS,
                output  VGA_VS,
                output  VGA_SYNC
                
                );

    


    vga dut(.clock(CLOCK_50),
            .reset(SW[0]),
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

    wire [9:0] x_addr, y_addr, vga_r, vga_g, vga_b;

    assign vga_r = (x_addr < 10'd160) ? 10'h3ff : 10'h7;
    assign vga_g = ((x_addr >= 10'd160) && (y_addr < 320)) ? 
                    10'h3ff : 10'h7;
    assign vga_b = (x_addr >= 10'd320) ? 10'h3ff : 10'h7;


endmodule



