//Quick ROM spun up using gates; should use ROM on FPGA.


module  PALROM(
                input [5:0] pal_in,

                output [7:0] red,
                output [7:0] green,
                output [7:0] blue
                );

    

    assign red =  pal_in == 'd0 ? 'd96 :
                  pal_in == 'd1 ? 'd0 :
                  pal_in == 'd2 ? 'd0 :
                  pal_in == 'd3 ? 'd60 :
                  pal_in == 'd4 ? 'd100 :
                  pal_in == 'd5 ? 'd100 :
                  pal_in == 'd6 ? 'd100 :
                  pal_in == 'd7 ? 'd81 :
                  pal_in == 'd8 ? 'd36 :
                  pal_in == 'd9 ? 'd28 :
                  pal_in == 'd10 ? 'd0 :
                  pal_in == 'd11 ? 'd0 :
                  pal_in == 'd12 ? 'd0 :
                  pal_in == 'd13 ? 'd0 :
                  pal_in == 'd14 ? 'd20 :
                  pal_in == 'd15 ? 'd20 :
                  pal_in == 'd16 ? 'd174 :
                  pal_in == 'd17 ? 'd36 :
                  pal_in == 'd18 ? 'd52 :
                  pal_in == 'd19 ? 'd116 :
                  pal_in == 'd20 ? 'd180 :
                  pal_in == 'd21 ? 'd180 :
                  pal_in == 'd22 ? 'd180 :
                  pal_in == 'd23 ? 'd136 :
                  pal_in == 'd24 ? 'd92 :
                  pal_in == 'd25 ? 'd56 :
                  pal_in == 'd26 ? 'd0 :
                  pal_in == 'd27 ? 'd0 :
                  pal_in == 'd28 ? 'd0 :
                  pal_in == 'd29 ? 'd48 :
                  pal_in == 'd30 ? 'd20 :
                  pal_in == 'd31 ? 'd20 :
                  pal_in == 'd32 ? 'd255 :
                  pal_in == 'd33 ? 'd88 :
                  pal_in == 'd34 ? 'd132 :
                  pal_in == 'd35 ? 'd184 :
                  pal_in == 'd36 ? 'd236 :
                  pal_in == 'd37 ? 'd248 :
                  pal_in == 'd38 ? 'd255 :
                  pal_in == 'd39 ? 'd222 :
                  pal_in == 'd40 ? 'd183 :
                  pal_in == 'd41 ? 'd122 :
                  pal_in == 'd42 ? 'd60 :
                  pal_in == 'd43 ? 'd52 :
                  pal_in == 'd44 ? 'd44 :
                  pal_in == 'd45 ? 'd76 :
                  pal_in == 'd46 ? 'd20 :
                  pal_in == 'd47 ? 'd20 :
                  pal_in == 'd48 ? 'd255 :
                  pal_in == 'd49 ? 'd192 :
                  pal_in == 'd50 ? 'd204 :
                  pal_in == 'd51 ? 'd228 :
                  pal_in == 'd52 ? 'd252 :
                  pal_in == 'd53 ? 'd255 :
                  pal_in == 'd54 ? 'd255 :
                  pal_in == 'd55 ? 'd244 :
                  pal_in == 'd56 ? 'd228 :
                  pal_in == 'd57 ? 'd204 :
                  pal_in == 'd58 ? 'd180 :
                  pal_in == 'd59 ? 'd180 :
                  pal_in == 'd60 ? 'd180 :
                  pal_in == 'd61 ? 'd182 :
                  pal_in == 'd62 ? 'd20 :
                  pal_in == 'd63 ? 'd20 : 0;
    
    
    assign green =  pal_in == 'd0 ? 'd96 :   
                    pal_in == 'd1 ? 'd44 :
                    pal_in == 'd2 ? 'd0 :
                    pal_in == 'd3 ? 'd0 :
                    pal_in == 'd4 ? 'd0 :
                    pal_in == 'd5 ? 'd0 :
                    pal_in == 'd6 ? 'd0 :
                    pal_in == 'd7 ? 'd24 :
                    pal_in == 'd8 ? 'd36 :
                    pal_in == 'd9 ? 'd52 :
                    pal_in == 'd10 ? 'd68 :
                    pal_in == 'd11 ? 'd68 :
                    pal_in == 'd12 ? 'd68 :
                    pal_in == 'd13 ? 'd0 :
                    pal_in == 'd14 ? 'd20 :
                    pal_in == 'd15 ? 'd20 :
                    pal_in == 'd16 ? 'd174 :
                    pal_in == 'd17 ? 'd88 :
                    pal_in == 'd18 ? 'd52 :
                    pal_in == 'd19 ? 'd36 :
                    pal_in == 'd20 ? 'd0 :
                    pal_in == 'd21 ? 'd24 :
                    pal_in == 'd22 ? 'd28 :
                    pal_in == 'd23 ? 'd60 :
                    pal_in == 'd24 ? 'd92 :
                    pal_in == 'd25 ? 'd108 :
                    pal_in == 'd26 ? 'd124 :
                    pal_in == 'd27 ? 'd124 :
                    pal_in == 'd28 ? 'd124 :
                    pal_in == 'd29 ? 'd48 :
                    pal_in == 'd30 ? 'd20 :
                    pal_in == 'd31 ? 'd20 :
                    pal_in == 'd32 ? 'd255 :
                    pal_in == 'd33 ? 'd160 :
                    pal_in == 'd34 ? 'd132 :
                    pal_in == 'd35 ? 'd116 :
                    pal_in == 'd36 ? 'd100 :
                    pal_in == 'd37 ? 'd108 :
                    pal_in == 'd38 ? 'd116 :
                    pal_in == 'd39 ? 'd150 :
                    pal_in == 'd40 ? 'd183 :
                    pal_in == 'd41 ? 'd198 :
                    pal_in == 'd42 ? 'd212 :
                    pal_in == 'd43 ? 'd200 :
                    pal_in == 'd44 ? 'd188 :
                    pal_in == 'd45 ? 'd76 :
                    pal_in == 'd46 ? 'd20 :
                    pal_in == 'd47 ? 'd20 :
                    pal_in == 'd48 ? 'd255 :
                    pal_in == 'd49 ? 'd216 :
                    pal_in == 'd50 ? 'd204 :
                    pal_in == 'd51 ? 'd200 :
                    pal_in == 'd52 ? 'd196 :
                    pal_in == 'd53 ? 'd200 :
                    pal_in == 'd54 ? 'd204 :
                    pal_in == 'd55 ? 'd216 :
                    pal_in == 'd56 ? 'd228 :
                    pal_in == 'd57 ? 'd236 :
                    pal_in == 'd58 ? 'd244 :
                    pal_in == 'd59 ? 'd236 :
                    pal_in == 'd60 ? 'd228 :
                    pal_in == 'd61 ? 'd182 :
                    pal_in == 'd62 ? 'd20 :
                    pal_in == 'd63 ? 'd20 : 0;

    assign blue =  pal_in == 'd0 ? 'd96 :
                   pal_in == 'd1 ? 'd112 :
                   pal_in == 'd2 ? 'd156 :
                   pal_in == 'd3 ? 'd128 :
                   pal_in == 'd4 ? 'd100 :
                   pal_in == 'd5 ? 'd60 :
                   pal_in == 'd6 ? 'd0 :
                   pal_in == 'd7 ? 'd0 :
                   pal_in == 'd8 ? 'd0 :
                   pal_in == 'd9 ? 'd0 :
                   pal_in == 'd10 ? 'd0 :
                   pal_in == 'd11 ? 'd44 :
                   pal_in == 'd12 ? 'd68 :
                   pal_in == 'd13 ? 'd0 :
                   pal_in == 'd14 ? 'd20 :
                   pal_in == 'd15 ? 'd20 :
                   pal_in == 'd16 ? 'd174 :
                   pal_in == 'd17 ? 'd184 :
                   pal_in == 'd18 ? 'd244 :
                   pal_in == 'd19 ? 'd212 :
                   pal_in == 'd20 ? 'd180 :
                   pal_in == 'd21 ? 'd104 :
                   pal_in == 'd22 ? 'd28 :
                   pal_in == 'd23 ? 'd24 :
                   pal_in == 'd24 ? 'd0 :
                   pal_in == 'd25 ? 'd0 :
                   pal_in == 'd26 ? 'd0 :
                   pal_in == 'd27 ? 'd72 :
                   pal_in == 'd28 ? 'd124 :
                   pal_in == 'd29 ? 'd48 :
                   pal_in == 'd30 ? 'd20 :
                   pal_in == 'd31 ? 'd20 :
                   pal_in == 'd32 ? 'd255 :
                   pal_in == 'd33 ? 'd232 :
                   pal_in == 'd34 ? 'd255 :
                   pal_in == 'd35 ? 'd255 :
                   pal_in == 'd36 ? 'd236 :
                   pal_in == 'd37 ? 'd176 :
                   pal_in == 'd38 ? 'd116 :
                   pal_in == 'd39 ? 'd68 :
                   pal_in == 'd40 ? 'd0 :
                   pal_in == 'd41 ? 'd40 :
                   pal_in == 'd42 ? 'd60 :
                   pal_in == 'd43 ? 'd124 :
                   pal_in == 'd44 ? 'd188 :
                   pal_in == 'd45 ? 'd76 :
                   pal_in == 'd46 ? 'd20 :
                   pal_in == 'd47 ? 'd20 :
                   pal_in == 'd48 ? 'd255 :
                   pal_in == 'd49 ? 'd252 :
                   pal_in == 'd50 ? 'd255 :
                   pal_in == 'd51 ? 'd255 :
                   pal_in == 'd52 ? 'd252 :
                   pal_in == 'd53 ? 'd228 :
                   pal_in == 'd54 ? 'd204 :
                   pal_in == 'd55 ? 'd184 :
                   pal_in == 'd56 ? 'd164 :
                   pal_in == 'd57 ? 'd172 :
                   pal_in == 'd58 ? 'd180 :
                   pal_in == 'd59 ? 'd204 :
                   pal_in == 'd60 ? 'd228 :
                   pal_in == 'd61 ? 'd182 :
                   pal_in == 'd62 ? 'd20 :
                   pal_in == 'd63 ? 'd20 : 0;


endmodule

