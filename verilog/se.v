//sprite engine
module  se(
                input clock,
                input reset,
                input [8:0] cycleNum,
                input [7:0] yCoord,
                //0 if 8x8, 1 if 8x16
                input sprite_size,
                input sPT_base, 
                input [7:0] vram2se_data,
                //inputs ...
                input  [7:0] OAMDATA, 
                
                
                //outputs ...  
                output [7:0] OAMADDR,
                output overflow_out,
                output se2vram_v,
                output [13:0] se2vram_addr, 
                output se2ppu_v,
                output se2ppu_p, //this is priority
                output [3:0] se2ppu_idx
                );


    parameter state_load_soam = 5'd0;
    parameter state_load_vram1 = 5'd1;
    parameter state_load_vram2 = 5'd2; 
    integer i; 
    reg [1:0] m, m_n;
    reg [5:0] n, n_n;
    reg [4:0] sOAM_idx, sOAM_idx_n; 
    reg [7:0] y, x, atr, nt, y_n, x_n, atr_n, nt_n;
   
    reg [4:0] state, state_n;

    reg overflow_n, overflow, w, w_n;
    wire sOAM_full, inverted_x, inverted_y;
    assign inverted_x = atr[6];
    assign inverted_y = atr[7];
    assign se2vram_v = (state != state_load_soam);


    wire [7:0] sOAM_out, y_offset; 
    reg [7:0] sprv, sprv_n;
    reg [7:0] sprPrio, sprPrio_n;
    reg [7:0] activated, activated_n;
    reg [7:0] [7:0] counters, counters_n;
    reg [7:0] [1:0] attrb, attrb_n;
    reg [7:0] [7:0] lBMr, lBMr_n;
    reg [7:0] [7:0] hBMr, hBMr_n;
    assign overflow_out = overflow | overflow_n; 
    assign sOAM_full = &sValid;
    assign y_offset = yCoord -y;
    wire sOAM_we;
    wire [7:0] sprite_height, flxData;

    assign sprite_height = sprite_size ? 'd16 : 'd8;


    wire observing_y, in_range;

    assign OAMADDR = {n, m};

    
   
    assign in_range =  OAMDATA <= yCoord && OAMDATA + sprite_height > yCoord;
    assign observing_y = OAMADDR[1:0] == 0 && ~sOAM_full;

    //secondary OAM valid signal 
    reg [7:0] sValid_n, sValid;
 


    bf flipper(.inb(vram2se_data), 
               .flipped(flxData));





    always @* begin
        activated_n = activated;
        counters_n = counters;
        lBMr_n = lBMr; 
        hBMr_n = hBMr;
        attrb_n = attrb;
        sprv_n = sprv;
        if (cycleNum < 'd257) begin
            if (cycleNum == 'd0) begin
                for (i = 0; i < 8; i = i + 1) begin 
                    if(counters[i] == 0) begin
                        activated_n[i] = 1'b1;
                    end
                end
            end else begin
                for (i = 0; i < 8; i = i + 1) begin 
                    if(sprv[i] && counters[i] == 1) begin
                        activated_n[i] = 1'b1;
                    end

                    if (sprv[i] && activated[i]) begin
                        counters_n[i] = counters[i] + 1'b1;
                        if (counters[i] == 'd7) begin
                            sprv_n[i] = 0;
                            activated_n[i] = 0;
                        end
                    end else if (sprv[i]) begin
                        counters_n[i] = counters[i] - 1'b1;
                    end

                end

            end

            for (i = 7; i >= 0; i = i - 1) begin
                if(sprv[i] && activated[i]) begin
                    se2ppu_v = 1'b1;
                    se2ppu_p = sprPrio[i];
                    se2ppu_idx = {attrb[i], hBMr[i][counters[i][2:0]], lBMr[i][counters[i][2:0]]};
                end
            end
        end
    end















    always@* begin
        sValid_n =sValid; 
        m_n = m + sOAM_we;
        n_n = n + {5'd0 ,((&m) & ~sOAM_full)};
        sOAM_we = |sOAM_idx[1:0] & cycleNum[0];
        overflow_n = overflow;
        sOAM_idx_n = sOAM_idx +  {4'd0, sOAM_we};
        
        
        if (cycleNum == 'd1) begin
            sValid_n = 0;
            overflow_n = 0; 
        end else if (cycleNum == 'd64) begin
            m_n = 0;
            n_n = 0;
            sOAM_idx_n = 0;  
        end else if (( cycleNum > 'd64) && (cycleNum < 'd257)) begin
            if(observing_y && cycleNum[0] && in_range && ~sOAM_full) begin
                sOAM_idx_n = sOAM_idx +'d1;
                sOAM_we = 'b1;                
                sValid_n[sOAM_idx[4:2]] = 'b1; 
            end else if ( observing_y && cycleNum[0] && ~in_range && ~sOAM_full) begin
                n_n = n + 'd1;
            end else if ( observing_y && cycleNum[0] && in_range && sOAM_full) begin
                overflow_n = 1'b1;
            end
        end else if (cycleNum > 'd256) begin 
        case(state) 

            state_load_soam: begin        
                if (sOAM_idx[1:0] == 2'b11) begin
                    state_n = state_load_vram1;
                    w_n = 0;
                end else begin
                    sOAM_idx_n= sOAM_idx + 1;
                end
                case (sOAM_idx[1:0]) 
                    2'b00: y_n = sOAM_out;
                    2'b01: nt_n= sOAM_out;
                    2'b10: atr_n= sOAM_out;
                    2'b11: x_n = sOAM_out;  
                endcase
            end

            
            state_load_vram1: begin
                if(w == 0) begin 
                    w_n = 1;
                    if(sprite_size) begin
                        se2vram_addr = {1'b0, nt[0], nt[7:1], 1'b0, inverted_y ? ~y_offset[3:0] : y_offset[3:0]};
                    end else begin
                        se2vram_addr = {1'b0, sPT_base, nt[7:0], 1'b0, inverted_y ? ~y_offset[2:0] : y_offset[2:0]};      
                    end
                end
                else if (w == 1) begin 
                    state_n = state_load_vram2;
                    w_n = 0;
                    lBMr_n[sOAM_idx[4:2]] = inverted_x ? flxData : vram2se_data;
                end
            end

            state_load_vram2: begin
                if(w == 0) begin 
                    w_n = 1;
                    if(sprite_size) begin
                        se2vram_addr = {1'b0, nt[0], nt[7:1], 1'b1, inverted_y ? ~y_offset[3:0] : y_offset[3:0]};
                    end else begin
                        se2vram_addr = {1'b0, sPT_base, nt[7:0], 1'b1, inverted_y ? ~y_offset[2:0] : y_offset[2:0]};      
                    end
                end
                else if (w == 1) begin 
                    sOAM_idx_n= sOAM_idx + 1;
                    state_n = state_load_soam;
                    w_n = 0;
                    hBMr_n[sOAM_idx[4:2]] = inverted_x ? flxData : vram2se_data;
                    state_n = state_load_soam;
                    counters_n[sOAM_idx[4:2]] = x;
                    sprv_n[sOAM_idx[4:2]] = sValid[sOAM_idx[4:2]];
                    sprPrio_n[sOAM_idx[4:2]] = atr[5]; 
                    attrb_n[sOAM_idx[4:2]] = atr[1:0];  
                 
                end
            end

           default:
                state_n = state_load_soam;

        endcase



        end

    end



    always @(posedge clock )begin
        if (reset) begin 
            sValid <= 0;
            n <= 0;
            m <= 0;
            overflow <= 0; 
            sOAM_idx <= 0;
            hBMr <= 0;
            lBMr <= 0;
            w <= 0;
            y <= 0;
            x <= 0;
            atr <= 0; 
            nt <=0;
            sprv <= 0;
            sprPrio <= 0;
            counters <= 0;
            activated <= 0;
            state <= 0;
            attrb <=0;
        end else begin
            state <= state_n;
            sValid <= sValid_n; 
            n <= n_n;
            m <= m_n;
            w <= w_n;
            overflow <= overflow_n;
            sOAM_idx <= cycleNum == 'd256 ? 0 : sOAM_idx_n;            
            hBMr <= hBMr_n; 
            lBMr <= lBMr_n;
            y <= y_n;
            x <= x_n;
            atr <= atr_n; 
            attrb <= attrb_n;
            nt <= nt_n;
            activated <= activated_n;
            counters <= counters_n;
            sprPrio <= sprPrio_n;
            sprv <= sprv_n; 
        end 
    end    

endmodule



