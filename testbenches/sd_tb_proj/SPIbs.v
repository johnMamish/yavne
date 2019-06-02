module SPIbs(input clock,
             input reset, 
             // input byte valid
             input wire ib_v, 
             // input byte value
             input wire [7:0] ib_in,
             output wire [7:0] rb_o,
             output wire idle,

             output wire byte_ready,
             output wire sclk,
             output wire mosi,
             input wire miso
             );

   
   
   
   
  

    assign sclk = divclk; 
    assign sclk = divclk & ib_v;
    assign byte_ready = (sc == 4'd7) & divcnt[2] & ~(|divcnt[1:0]);
    reg [7:0] wb; 
    
    reg [6:0] divcnt;
    reg [3:0] sc;
	reg [6:0] rb;
	reg tr;
    wire divclk;

    assign divclk = divcnt[2];
    assign idle =  (sc > 4'd7) & ~ib_v;
    assign mosi = wb[7];
    assign rb_o = {rb[6:0], tr};


    always @(posedge clock )begin
        if (reset) begin
            divcnt <= 0;
        end else begin
            divcnt <= idle ? 0 :  divcnt +1'b1;
        end 
    end


    always @(posedge divclk) begin 
        tr <= miso;
        
    end 

    always @(negedge divclk or posedge reset ) begin
		  if (reset) begin
				rb <= 7'd0;
				wb <= ib_in;
				sc <= 4'd0;
		  end else begin
				rb         <= ((sc == 4'd7) & ib_v) ? 7'd0  : {rb[5:0], tr};
				wb         <= ((sc == 4'd7) & ib_v) ? ib_in : {wb[6:0], 1'b0};
				sc         <= ((sc >= 4'd7) & ib_v) ? 4'd0  : sc + 1'b1;
			end
    end

endmodule


