// palram is small enough that we use flops
module  pram(
                input clock,
                input reset, 
                input we,
                input [12:0] w_addr,
                input [5:0] w_data,
                
                input [4:0] r_addr,

                output [5:0] r_data
 
                );

    
    reg [4:0] [5:0] palram;

    reg [4:0] index;

    assign r_data = palram[r_addr];

    always @* begin
        case (w_addr[4:0]) 
            5'h10: index = 5'd0;
            5'h14: index = 5'h4;
            5'h18: index = 5'h8;
            5'h1c: index = 5'hc;
            default: index = w_addr[4:0];
        endcase

    end


    always @(posedge clock )begin
        if (reset) begin
            palram <= 0;
        end else begin
            palram[index] <= we ? w_data : palram[index];
        end 
    end    

endmodule



