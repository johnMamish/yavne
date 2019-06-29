module  simram(
                input clock,
                input reset,
                input we,
                input [14:0] w_addr,
                input [7:0] w_data,

                input [14:0] r_addr,

                output [7:0] r_data

                );


    reg [14:0] [7:0] palram;

    reg [4:0] index;

    assign r_data = palram[r_addr];

    always @(posedge clock )begin
        if (reset) begin
            palram <= 0;
        end else begin
            palram[index] <= we ? w_data : palram[index];
        end
    end

endmodule



