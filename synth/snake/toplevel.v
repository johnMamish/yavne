// memory map:
// $0000 - $01ff:   RAM, except $fe holds a random 8-bit number and $ff holds last pressed key
// $0200 - $05ff:   screen
// $0600 - $07ff:   program ROM
// $4000 - $4002:   leds

module peripherals(input             CLOCK_50,
                   input             nreset,
                   input             clock,
                   input [15:0]      addr,
                   input             rw,
                   input [7:0]       data_in,
                   output reg [7:0]  data_out,

                   output wire [9:0] VGA_R,
                   output wire [9:0] VGA_B,
                   output wire [9:0] VGA_G,
                   output wire       VGA_CLK,
                   output wire       VGA_BLANK,
                   output wire       VGA_HS,
                   output wire       VGA_VS,
                   output wire       VGA_SYNC,

                   input [3:0]       keys,
                   output reg [23:0] leds,
                   
                   input  wire       controller1_data);

   reg [7:0] ram [0:511];
   initial begin
      $readmemh("zeros.mem", ram);
   end

   reg [7:0] rom [0:1024];
   initial begin
      $readmemh("prog.mem", rom);
   end

   wire [7:0] data_from_vga;
   mmio_vga mmio_vga(.CLOCK_50(CLOCK_50),
                     .reset(~nreset),
                     .addr(addr),
                     .data(data_in),
                     .rw(rw),
                     .VGA_R(VGA_R),
                     .VGA_B(VGA_B),
                     .VGA_G(VGA_G),
                     .VGA_CLK(VGA_CLK),
                     .VGA_BLANK(VGA_BLANK),
                     .VGA_HS(VGA_HS),
                     .VGA_VS(VGA_VS),
                     .VGA_SYNC(VGA_SYNC),
                     .rd_addr(),
                     .vga_data(data_from_vga));


   reg [3:0]  keys_prev;
   reg [7:0]  pressedkey;
   // update keys
   always @ (negedge clock) begin
      if (nreset) begin
         if (keys[0] != keys_prev[0]) begin
	    // 'd'
	    pressedkey <= 8'h64;
         end else if (keys[1] != keys_prev[1]) begin
	    // 's'
	    pressedkey <= 8'h73;
	 end else if (keys[2] != keys_prev[2]) begin
	    // 'w'
	    pressedkey <= 8'h77;
	 end else if (keys[3] != keys_prev[3]) begin
	    // 'a'
	    pressedkey <= 8'h61;
	 end else begin
	    pressedkey <= pressedkey;
	 end
      end else begin
         pressedkey <= 8'h73;
      end
      keys_prev <= keys;
   end

   always @ (negedge clock) begin
      // ram is only mapped at $0000 - $01ff
      if (addr < 'h0200) begin
         if(rw == 1'b0) begin
            ram[addr] <= data_in;
            data_out  <= 8'b0;
         end else begin
            // random number is mapped at $00fe
            if (addr == 'h00fe) begin
               data_out <= 'ha5;
            end
         
            // least-recent key is mapped at $00ff 
            else if (addr == 'h00ff) begin
               data_out <= pressedkey;
            end else begin
               data_out <= ram[addr];
            end
         end
      end

      // screen $0200 to $05ff
      else if ((addr >= 'h0200) && (addr < 'h0600)) begin
         data_out <= data_from_vga;
      end

      // rom $8000 to $ffff is $0400 bytes and is mirrored 32x
      else if ((addr >= 'h8000) && (addr <= 'hffff)) begin
         if(rw == 1'b1) begin
            data_out <= rom[addr[9:0]];
         end
      end

      // LEDs and buttons
      else begin
      // only can read buttons
         if (rw == 1'b0) begin
            case(addr)
            'h4000: leds[7:0] <= data_in;
            'h4001: leds[15:8] <= data_in;
            'h4002: leds[23:16] <= data_in;
            endcase
         end else begin
            case(addr)
               'h4016: data_out <= {7'b0, controller1_data};
            endcase
         end   
      end
   end
endmodule

/**
 * ==0==
 *|     |
 *6     1
 *|     |
 * ==5==
 *|     |
 *4     2
 *|     |
 * ==3==
 */
module hexled(input [3:0] in,
              output reg [6:0] out);

   always @ * begin
      case(in)
         4'h0: out = ~7'b011_1111;
         4'h1: out = ~7'b000_0110;
         4'h2: out = ~7'b101_1011;
         4'h3: out = ~7'b100_1111;
         4'h4: out = ~7'b110_0110;
         4'h5: out = ~7'b110_1101;
         4'h6: out = ~7'b111_1101;
         4'h7: out = ~7'b000_0111;
         4'h8: out = ~7'b111_1111;
         4'h9: out = ~7'b110_0111;
         4'ha: out = ~7'b111_0111;
         4'hb: out = ~7'b111_1100;
         4'hc: out = ~7'b011_1001;
         4'hd: out = ~7'b101_1110;
         4'he: out = ~7'b111_1001;
         4'hf: out = ~7'b111_0001;
      endcase
   end
endmodule

module ricoh_2a03_synth(input           CLOCK_50,
                        input           cpu_nrst,
                        input [3:0]     KEY,
                        input [17:1]      SW,
                        
                        output [17:0]     LEDR,
                        output [7:0]      LEDG,
                        
                        output [6:0]      HEX0,
                        output [6:0]      HEX1,
                        output [6:0]      HEX2,
                        output [6:0]      HEX3,
                        output [6:0]      HEX4,
                        output [6:0]      HEX5,
                        output [6:0]      HEX6,

                        output wire [9:0] VGA_R,
                        output wire [9:0] VGA_B,
                        output wire [9:0] VGA_G,
                        output wire       VGA_CLK,
                        output wire       VGA_BLANK,
                        output wire       VGA_HS,
                        output wire       VGA_VS,
                        output wire       VGA_SYNC,
                        
                        output wire       controller1_clk,
                        output wire       controller1_strobe,
                        input  wire       controller1_data);

   // generate clock
   reg [31:0]                             clk_div;
   always @ * begin
      case(SW[4:2])
         'h7: clk_div = 14;
         'h6: clk_div = 100;
         'h5: clk_div = 1000;
         'h4: clk_div = 5000;
         'h3: clk_div = 10000;
         'h2: clk_div = 100000;
         'h1: clk_div = 1000000;
         'h0: clk_div = 10000000;
      endcase
   end

   wire pll_out;
   sys_pll sys_pll(CLOCK_50, pll_out);
   
   reg             pll_div;
   reg [31:0]      pll_div_ctr;
   always @ (posedge pll_out) begin
      if (SW[1]) begin
         pll_div_ctr <= pll_div_ctr;
      end else begin
         pll_div_ctr <= pll_div_ctr + 'h1;
      end

      if (pll_div_ctr > clk_div) begin
         pll_div_ctr <= 'h0;
         pll_div = ~pll_div;
      end
   end

   // hook up memory and cpu
   wire[2:0] cyc_count;
   wire [15:0] addr;
   wire [7:0]  data_from_cpu;
   wire [7:0]  data_from_mem;
   wire        rw;

   assign LEDR[17] = rw;

   hexled pc_0(addr[3:0], HEX0);
   hexled pc_1(addr[7:4], HEX1);
   hexled pc_2(addr[11:8], HEX2);
   hexled pc_3(addr[15:12], HEX3);

   hexled wazzle({1'b0, cyc_count}, HEX6);

   hexled dat0((rw) ? data_from_mem[3:0] : data_from_cpu[3:0], HEX4);
   hexled dat1((rw) ? data_from_mem[7:4] : data_from_cpu[7:4], HEX5);

   assign controller1_clk = !(rw && (addr == 'h4016));
   
   wire [2:0] addr4016w_bundle;
   assign controller1_strobe = addr4016w_bundle[0];
   
   cpu_2a03 cpu(.clock(pll_div),
                .nreset(cpu_nrst),
                .addr(addr),
                .data_out(data_from_cpu),
                .data_in(data_from_mem),
                .rw(rw),
                .nnmi(SW[7]),
                .nirq(1'b1),
                .naddr4016r(),
                .naddr4017r(),
                .addr4016w(addr4016w_bundle),
                .cycs(cyc_count));

   peripherals p(.CLOCK_50(CLOCK_50),
                 .nreset(cpu_nrst),
                 .clock(pll_div),
                 .addr(addr),
                 .rw(rw),
                 .data_in(data_from_cpu),
                 .data_out(data_from_mem),

                 .VGA_R(VGA_R),
                 .VGA_B(VGA_B),
                 .VGA_G(VGA_G),
                 .VGA_CLK(VGA_CLK),
                 .VGA_BLANK(VGA_BLANK),
                 .VGA_HS(VGA_HS),
                 .VGA_VS(VGA_VS),
                 .VGA_SYNC(VGA_SYNC),

                 .keys(KEY[3:0]),
                 .leds({LEDG, LEDR[15:0]}),
                 
                 .controller1_data(controller1_data));
endmodule
