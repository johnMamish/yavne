module  simram(
                input clock,
                input reset,
                input we,
                input [15:0] w_addr,
                input [7:0] w_data,

                input [13:0] r_addr,

                output [7:0] r_data

                );

    
    reg [13:0] [7:0] palram;

    

    assign r_data = palram[r_addr];

    always @(posedge clock )begin
        if (reset) begin
            palram <= 0;
        end else begin
            palram[w_addr[13:0]] <= we ? w_data : palram[w_addr[13:0]];
        end
    end

endmodule



