module  PPU(
                input clock,
                input reset,
                //inputs ...
                input [7:0] vram2ppu_data,
                input [15:0] cpu2ppu_addr,
                input [7:0]  cpu2ppu_data,
                input cpu2ppu_wr,

                //outputs ...
                output [15:0] ppu2cpu_addr,
                output [7:0]  ppu2cpu_data,
                output [13:0] ppu2vram_addr,
                output [7:0] ppu2vram_data,
                output [4:0] pal_index,
                output [8:0] xIdx,
                output [8:0] yIdx
                );


    reg [7:0] PPUCTRL, PPUMASK, PPUSTAT, OAMADD, OAMDAT, PPUADD, PPUDAT;
    reg [7:0] bgA, bgL, atb;
    reg [15:0] NT_base;
    reg [1:0] attrL;
    reg [2:0] x, next_x, ctr;
    reg [1:0] [15:0] bgSR, next_bgSR;
    reg [1:0] [7:0] attrSR;
    reg [14:0] tvram, vram, next_tvram, next_vram;
    reg w, next_w;
    reg [8:0] renderLine, cycleNum;


    wire [4:0] bgPalIdx;
    wire [15:0] sPT_base, bPT_base;
    wire [4:0] cy; //the "coarse" y
    wire [13:0] ptAddr;
    wire hInc;
    wire [2:0] fineY;
    wire [14:0] tileAddr, attrAddr;


    assign xIdx = cycleNum;
    assign yIdx = renderLine;
    assign bgPalIdx = {1'b0, attrSR[1][x], attrSR[0][x], bgSR[1][{1'b0,x}], bgSR[0][{1'b0, x}]};
    assign pal_index = bgPalIdx;



    //This describes the 2-bit attribute latch for the background
    always @(reset or hInc) begin
        if(reset) begin
            attrL = 0;
        end else if (hInc) begin
            case({cy[0], vram[0]})
                2'b00 : attrL = atb[1:0];
                2'b01 : attrL = atb[3:2];
                2'b10 : attrL = atb[5:4];
                2'b11 : attrL = atb[7:6];
            endcase
        end
    end










    assign fineY = vram[14:12];


    assign hInc = (ctr == 3'd7) && ((cycleNum > 'd0 && cycleNum < 'd257) || (cycleNum > 'd320 && cycleNum < 'd337)) ;


    //pattern table Address for the BACKGROUND
    assign ptAddr = { 1'b0,  PPUCTRL[4], bgA, &ctr[2:1], fineY};

    assign sPT_base = PPUCTRL[3] ? 'h1000 : 0;
    assign bPT_base = PPUCTRL[4] ? 'h1000 : 0;

    assign cy = vram[9:5];
    // This is doing the math to find the nametable address
    // NESdev isn't great for really describing the nametable; each entry is a pointer into the background
    // as far as I can tell.
    assign tileAddr = 'h2000 | (vram & 'h0fff);
    assign attrAddr = 'h23c0 | (vram & 'h0c00) | {4'h0, (vram[11:4]  & 8'h38 ), (vram[4:2] & 3'h7)};




    always @* begin
        next_tvram = tvram;
        next_vram = vram + {14'h0, hInc}; //there has to be a smarter way than this
        next_bgSR = bgSR;
        next_x = x;
        next_w = w;

        //shift logic


        if ((cycleNum > 'd0 && cycleNum < 'd257) || (cycleNum > 'd320 && cycleNum < 'd337)) begin
            next_bgSR[0] = {1'b0, bgSR[0][14:0]};
            next_bgSR[1] = {1'b0, bgSR[1][14:0]};
            if (hInc) begin
                next_bgSR[0][15:8] = bgL;
                next_bgSR[1][15:8] = vram2ppu_data;
            end
        end



        case(PPUCTRL[1:0])
            2'b00 : NT_base  = 'h2000;
            2'b01 : NT_base  = 'h2400;
            2'b10 : NT_base  = 'h2800;
            2'b11 : NT_base  = 'h2c00;
            default: NT_base = 'h2000;
        endcase

        casez (ctr[2:1])
            2'b00 : ppu2vram_addr = tileAddr[13:0];
            2'b01 : ppu2vram_addr = attrAddr[13:0];
            2'b1? : ppu2vram_addr = ptAddr;
        endcase

        if (hInc && ((vram & 'h001f) == 'h001f)) begin
            //If we go across a nametable, switch lower the nametable bit
            next_vram = ((vram & ~'h001f) ^ 'h0400);
        end





        if (cycleNum == 'd256) begin
            //If fine Y is less than 7, we increment fine Y bits
            if((vram & 'h7000) != 'h7000) begin
                next_vram = vram + 'h1000;
            end else begin
                next_vram = vram & ~'h7000;
                if (cy == 'd29) begin
                    next_vram[9:5] = 0;
                    next_vram[11] = next_vram[11] ^ 1'b1;
                end else if (cy == 'd31) begin
                    next_vram[9:5] = 0;
                end else begin
                    next_vram[9:5] = next_vram[9:5] + 1'b1;
                end
            end
        end

        if (cycleNum == 'd257) begin
            next_vram[10] = tvram[10];
            next_vram[4:0] = tvram[4:0];
        end


        if (cycleNum > 'd279 && cycleNum < 'd305 && renderLine == 'd261) begin
            next_vram[14:11] = tvram[14:11];
            next_vram[9:5]   = tvram[9:5];
        end




        if (cpu2ppu_wr && cpu2ppu_addr == 'h2000) begin
            next_tvram = {tvram[14:12], cpu2ppu_data[1:0], tvram[9:0]};
        end else if (w== 0 && cpu2ppu_wr && cpu2ppu_addr == 'h2005) begin
            next_tvram = {tvram[14:5], cpu2ppu_data[7:3]};
            next_x = cpu2ppu_data[2:0];
            next_w = 1;
        end else if (w==1 &&cpu2ppu_wr && cpu2ppu_addr == 'h2005) begin
            next_tvram = {cpu2ppu_data[2:0], tvram[11:10], cpu2ppu_data[7:3], tvram[4:0]};
            next_w = 0;
        end else if (w== 0 && cpu2ppu_wr && cpu2ppu_addr == 'h2006) begin
            next_tvram = {1'b0, cpu2ppu_data[5:0], tvram[7:0]};
            next_w = 1;
        end else if (w==1 &&cpu2ppu_wr && cpu2ppu_addr == 'h2006) begin
            next_tvram = {tvram[14:8], cpu2ppu_data[7:0]};
            next_vram = next_tvram;
            next_w = 0;
        end
    end



    always @(posedge clock )begin
        if (reset) begin
            PPUCTRL <= 0;
            PPUMASK <= 0;
            PPUSTAT <= 0;
            OAMADD  <= 0;
            OAMDAT  <= 0;
            PPUADD  <= 0;
            PPUDAT  <= 0;
            tvram   <= 0;
            vram    <= 0;
            renderLine <= 'd261;
            cycleNum   <= 'd0;
            ctr     <= 0;
            w       <= 0;
            bgSR    <= 0;
            bgL     <= 0;
            ppu2cpu_data <=0;
            ppu2cpu_addr <=0;
            attrSR <= 0;
        end else begin
            PPUCTRL <= (cpu2ppu_wr && cpu2ppu_addr == 'h2000) ? cpu2ppu_data : PPUCTRL;
            PPUMASK <= (cpu2ppu_wr && cpu2ppu_addr == 'h2001) ? cpu2ppu_data : PPUMASK;
            PPUSTAT <= (cpu2ppu_wr && cpu2ppu_addr == 'h2002) ? cpu2ppu_data : PPUSTAT;
            OAMADD  <= (cpu2ppu_wr && cpu2ppu_addr == 'h2003) ? cpu2ppu_data : OAMADD;
            OAMDAT  <= (cpu2ppu_wr && cpu2ppu_addr == 'h2004) ? cpu2ppu_data : OAMDAT;
            PPUADD  <= (cpu2ppu_wr && cpu2ppu_addr == 'h2006) ? cpu2ppu_data : PPUADD;
            PPUDAT  <= (cpu2ppu_wr && cpu2ppu_addr == 'h2007) ? cpu2ppu_data : PPUDAT;
            tvram   <= next_tvram;
            vram    <= next_vram;
            x       <= next_x;
            w       <= next_w;
            renderLine <= (cycleNum == 'd340) ? renderLine + 'd1 : renderLine;
            cycleNum <= (cycleNum == 'd340) ? 0 : cycleNum + 'd1;
            ctr      <= (cycleNum == 0) ? 0 : ctr + 'd1;
            bgSR    <= next_bgSR;
            if (ctr == 'd1) begin
                bgA <= vram2ppu_data;
            end
            if (ctr == 'd3) begin
               atb <=  vram2ppu_data;
            end
            if (ctr == 'd5) begin
                bgL <= vram2ppu_data;
            end
            attrSR[0] <= {attrL[0], attrSR[0][7:1]};
            attrSR[1] <= {attrL[1], attrSR[1][7:1]};
        end
    end

endmodule
