module  mmio_vga_tb(
                input CLOCK_50,
                input [1:0] SW,
                output wire [9:0] VGA_R, 
                output wire [9:0] VGA_B,
                output wire [9:0] VGA_G,
                output wire  VGA_CLK,
                output wire  VGA_BLANK, 
                output wire  VGA_HS,
                output wire  VGA_VS,
                output wire  VGA_SYNC,
					 output wire [17:0] LEDR,
					 output wire [7:0] LEDG
                );

    



    mmio_vga dut(.CLOCK_50(CLOCK_50),
            .reset(SW[0]),
            .clock(divclk),
            .addr(addr),
            .data(data),
            .VGA_R(VGA_R),
            .VGA_B(VGA_G),
            .VGA_G(VGA_B),
            
            
            .VGA_CLK(VGA_CLK),
            .VGA_SYNC(VGA_SYNC),
            .VGA_HS(VGA_HS),
            .VGA_VS(VGA_VS),
            .VGA_BLANK(VGA_BLANK),
			.rd_addr(LEDR[9:0])); 
			
	 
    assign LEDG[1] = divclk;
	 reg [15:0] addr;
    reg [7:0] data;
	 reg [4:0] clkdiv;
    wire divclk;
	 assign divclk = clkdiv[4];
	 assign LEDR[14] = LEDR  > 500 && LEDR < 600; 
	 always @(posedge CLOCK_50) begin
		if(SW[0]) begin
			clkdiv <= 0;
		end else begin
			clkdiv <= clkdiv + 1'b1;
		end
	end
	 
	 


    always @(negedge divclk) begin
        if (SW[0]) begin
            addr <= 16'h200;
            data <= 0;
        end else begin
            addr <= (addr < 16'h5ff) ? addr + 1'b1 : 16'h200;
            data <= addr[0] ^ addr[5];
        end
    end
    
    
    
    

endmodule



