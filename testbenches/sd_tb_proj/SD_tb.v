module SD_tb(input wire OSC_50,
             input wire [2:0] SW,
             output wire [7:0] LED_GREEN,
             output wire [17:0] LED_RED,
             input wire SD_MISO,
             output wire SD_MOSI,
             output wire SD_CLK,
             output wire SD_SS,
				 output wire [4:0] GPIO
             );




assign LED_RED[5] = SW[2];

reg [23:0] clockdiv;

assign GPIO[0] = SD_MISO;
assign GPIO[1] = SD_MOSI;
assign GPIO[2] = SD_CLK;
assign GPIO[3] = SD_SS;

wire clock;
assign LED_RED[7] = clockdiv[23];
assign clock = clockdiv[4];

reg [31:0] in_addr;
wire [7:0] next_state;
wire [7:0] sd_byte;
wire valid_read;
wire idle;


always @(posedge OSC_50) begin
	if (SW[0])
		clockdiv <= 0;
	else
		clockdiv <= clockdiv + 1'b1;
end

always @(posedge clock) begin
    if (SW[1]) 
        in_addr <= 0;
    else
        in_addr <= idle ? 
						 in_addr > 32'hFFFF00 : 32'd0 ?
						 in_addr + 32'h100 : in_addr;
		  
end




assign LED_RED[6] = SD_SS;





SDIF    dut(.clock(clock),
            .reset(SW[1]),
            .in_addr(in_addr),
            .begin_read(SW[2]),
            
             .idle(idle),
             .valid_read(valid_read),
             .sd_byte(sd_byte),


            .miso(SD_MISO),
            .ss(SD_SS),              
             .sclk(SD_CLK),
             .mosi(SD_MOSI), 
            .state(LED_RED[4:0]),
				.dleds(next_state));

				
				assign LED_GREEN  = valid_read ? sd_byte : next_state;

endmodule
