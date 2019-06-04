module  vga(
                input clock,
                input reset, 
                //inputs ... 
                input  [9:0] vga_r,               
                input  [9:0] vga_g,
                input  [9:0] vga_b,
                //outputs ...  
                output reg [9:0] vga_r_DAC,
                output reg [9:0] vga_g_DAC,
                output reg [9:0] vga_b_DAC,
                output wire  [9:0] x_addr,
                output wire  [9:0] y_addr,
                output reg vga_clock,
                output wire vga_sync_dac,
                output wire vga_hs,
                output wire vga_vs,
                output wire vga_blank
                
                );

    //640x480 display, due to the only clock availible being 25Mhz w/o touching PLL


    
    parameter state_idle = 5'd0;

    parameter H_SYNC_LOW = 10'd96;
    parameter H_SYNC_BP  = 10'd48;
    parameter H_SYNC_FP  = 10'd16;
    parameter H_SIZE     = 10'd640;
    parameter H_RESET = H_SIZE + H_SYNC_LOW + H_SYNC_BP + H_SYNC_FP;
    parameter H_BEGIN =  H_SYNC_LOW + H_SYNC_BP + H_SYNC_FP;
    parameter V_SYNC_LOW = 10'd2;
    parameter V_SYNC_BP  = 10'd33;
    parameter V_SYNC_FP  = 10'd10;
    parameter V_SIZE     = 10'd480;
    parameter V_RESET = V_SIZE + V_SYNC_LOW + V_SYNC_BP + V_SYNC_FP;
    parameter V_BEGIN = V_SYNC_LOW + V_SYNC_BP + V_SYNC_FP;

     
    reg [9:0] x_cnt, y_cnt;
    assign x_addr = (x_cnt >= H_BEGIN) ? x_cnt - H_BEGIN : 10'd0;
    assign y_addr = (y_cnt >= V_BEGIN ) ? y_cnt - V_BEGIN : 10'd0;
    assign vga_sync_dac = 1'b0;
    assign vga_blank = vga_hs & vga_vs;
    assign vga_hs = ~((x_cnt >= H_SYNC_FP) &&  
                    (x_cnt <  H_SYNC_FP + H_SYNC_LOW));
    assign vga_vs = ~((y_cnt >= V_SYNC_FP) &&  
                    (y_cnt <  V_SYNC_FP + V_SYNC_LOW));

    always @(posedge clock )begin
        if (reset) begin
            x_cnt <= 0;
            y_cnt <= 0;
            vga_clock <= 0; 
        end else begin
            // this assumes a 50MHz clock;
            vga_clock <= ~vga_clock;
            if (vga_clock) begin 
                if (x_cnt >= H_RESET) begin

                    x_cnt <= 0;

                    if( y_cnt >= V_RESET) begin
                        y_cnt <= 0;
                    end else begin 
                        y_cnt <= y_cnt + 1'b1;
                    end
                end else begin
                    x_cnt <= x_cnt +1'b1;
                end
                
                
                if (x_cnt >= H_BEGIN && y_cnt >= V_BEGIN ) begin
                    vga_r_DAC <=    vga_r;
                    vga_g_DAC <=    vga_g;
                    vga_b_DAC <=    vga_b;
                end else begin
                    vga_r_DAC <=    0; 
                    vga_g_DAC <=    0;
                    vga_b_DAC <=    0;
                end 
            end




        end 
    end    

endmodule



