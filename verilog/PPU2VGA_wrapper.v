module  PPU2VGA_wrapper(
                    input CLOCK_50,
                    input clock,
                    input reset,
                    //inputs ...
                    input [7:0] vram2ppu_data,
                    input [15:0] cpu2ppu_addr,
                    input [7:0]  cpu2ppu_data,
                    input cpu2ppu_wr,

                    //outputs ...
                    output [15:0] ppu2cpu_addr,
                    output [7:0]  ppu2cpu_data,
                    output [13:0] ppu2vram_addr,
                    output [7:0] ppu2vram_data,
                    output [4:0] bg_pal_index,
                    output [4:0] se_pal_index,
                    //output wire  [8:0] xIdx,
                    //output wire  [8:0] yIdx

                    output reg [9:0] VGA_R,
                    output reg [9:0] VGA_B,
                    output reg [9:0] VGA_G,
                    //output wire  [9:0] x_addr,
                    //output wire  [9:0] y_addr,
                    output reg VGA_CLK,
                    output wire VGA_SYNC,
                    output wire VGA_HS,
                    output wire VGA_VS,
                    output wire VGA_BLANK

                );


    //TODO: instantiate ram in here

    simram pram(
    .clock  (clock ),
    .reset  (reset ),
    .we     (cpu2ppu_wr),
    .w_addr (cpu2ppu_addr),
    .w_data (cpu2ppu_data),
    .r_addr (ppu2vram_addr),
    .r_data (ppu2vram_data));

    wire  [4:0] pal_idx; 
    wire  [8:0] xIdx;
    wire  [8:0] yIdx;
    wire  [9:0] x_addr;
    wire  [9:0] y_addr;
    wire  [7:0] vga_r, vga_b, vga_g;

    wire  [12:0] read_addr, write_addr;

    wire [9:0] xminus1;


    assign xminus1 = xIdx -1'b1;



    assign read_addr = {y_addr[5:1], x_addr[8:1]};
    assign write_addr = { yIdx[4:0], xminus1[7:0]};

    PPU nt( //inputs
            .clock(clock),
            .reset(reset),
            .vram2ppu_data(vram2ppu_data),
            .cpu2ppu_addr(cpu2ppu_addr),
            .cpu2ppu_data(cpu2ppu_data),
            .cpu2ppu_wr(cpu2ppu_wr),

        //outputs ...
            .ppu2cpu_addr(ppu2cpu_addr),
            .ppu2cpu_data(ppu2cpu_data),
            .ppu2vram_addr(ppu2vram_addr),
            .ppu2vram_data(ppu2vram_data),
            .pal_index(bg_pal_index),
            .xIdx(xIdx),
            .yIdx(yIdx)
        );



    PALROM tl(
            .pal_in({1'b0, bg_pal_index}), //TODO: fix CDC
            .red(vga_r),
            .green(vga_g),
            .blue(vga_b));

    vga vga_driver(.clock(CLOCK_50),
            .reset(reset),
            .vga_r({vga_r, vga_r[7:6]}),
            .vga_g({vga_g, vga_g[7:6]}),
            .vga_b({vga_b, vga_b[7:6]}),
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

endmodule
