module SPIbs(input clock,
             input reset, 
             // input byte valid
             input wire ib_v, 
             // input byte value
             input wire [7:0] ib_in,
             output wire [7:0] rb_o,

             output wire byte_ready,
             output wire sclk,
             output wire mosi,
             input wire miso
             );

   
   
   
   
  
    assign sclk = divclk & ib_v;
    assign byte_ready = (sc == 4'd7) & divcnt[3] & ~(|divcnt[2:0]);
    reg [7:0] wb; 
    
    reg [6:0] divcnt;
    reg [3:0] sc;
	reg [7:0] rb;
	reg tr;
    wire divclk;

    assign divclk = divcnt[3];
   
    assign mosi = wb[0];
    assign rb_o = {rb[6:0], tr};


    always @(posedge clock or posedge reset) begin

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


