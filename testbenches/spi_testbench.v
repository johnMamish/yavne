module spi_testbench;
                     
                
integer i, j;
reg clock;
reg reset;
reg miso;

wire mosi, sclk;

always
begin
   #5
    clock = ~clock;

end



reg [7:0] readme;
reg ib_v; 
wire [7:0] rb_o;



SPIbs    dut(.clock(clock),
             .reset(reset), 
           
             .ib_v(ib_v), 
          
             .ib_in(ib_in),
             .rb_o(rb_o),

             .byte_ready(byte_ready),
             .sclk(sclk),
             .mosi(mosi),
             .miso(miso)
             );

initial begin
    clock = 1'b0;
    reset = 1'b1;
    ib_v = 1'b1;
    @(negedge clock);
    reset = 1'b0;
    for( j =0; j < 255; j = j + 1) begin
        readme = j; 
        for( i =0; i < 8; i = i +1) begin
            miso = readme[7-i];
            @ (negedge sclk);
        end
        if(readme != rb_o) begin
				$display("NO GOD");
			end
    end
end
    
endmodule




