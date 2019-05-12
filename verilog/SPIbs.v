module SPIbs(input clock,
             input reset,
             //how much we divide by
             input wire [3:0] divider,
             // input byte valid
             input wire ib_v, 
             // input byte value
             input wire [7:0] ib_in,
             output wire [7:0] rb_o,

             output wire byte_ready,
             output wire sclk,
             output wire mosi,
             output wire ss,
             input wire miso
             );

   
   
   
   
  
    assign sclk = ib_v & divclk;
    assign byte_ready = (sc == 4'd7) & sclk;
    reg [7:0] wb; 
    reg [3:0] state, next_state;
    reg [6:0] divcnt;
    reg [3:0] sc;
	 reg [7:0] rb;
	 reg tr;
    wire divclk;

    assign divclk = divcnt[divider];
    assign ss = ib_v;
    assign mosi = wb[0];
    assign rb_o = {rb[6:0], tr};


    always @(posedge clock) begin

        if (reset) begin
            divcnt <= 0;
        end

        divcnt <= divcnt +1; 
    end


    always @(posedge divclk) begin 
        tr <= miso;
        
    end 

    always @(negedge divclk or posedge reset) begin
       
        rb         <= (reset | ((sc == 4'd7) & ib_v)) ? 8'd0  : {rb[6:0], tr};
        wb         <= (reset | ((sc == 4'd7) & ib_v)) ? ib_in : {1'b0, wb[7:1]};
        sc         <= (reset | ((sc == 4'd7) & ib_v)) ? 4'd0  : sc + 1;
    end

endmodule


