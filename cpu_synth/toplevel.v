// connect a cpu to 2 buttons (memory mapped at LSB of $4000 and $4001)
// and 3 sets of 8 LEDs (red leds are mapped at $4002 and $4003; green are $4004)

module peripherals(input clock,
                   input [15:0]      addr,
                   input             rw,
                   input [7:0]       data_in,
                   output reg [7:0]  data_out,

                   input  [1:0]      buttons,
                   output reg [23:0] leds);

   reg [7:0] ram [0:63];

   reg [7:0] rom [0:63];
   initial begin
      $readmemh("prog.mem", rom);
   end

   always @ (posedge clock)
     begin
        // only have 1024 bytes of ram
        if (addr[15:10] == 'h0) begin
           if(rw == 1'b0) begin
              ram[addr] <= data_in;
              data_out  <= 8'b0;
           end else begin
              data_out <= ram[addr[9:0]];
           end
        end

        // 1024 bytes rom starting at $1000
        else if (addr[15:10] == 'b0001_00) begin
           if(rw == 1'b1) begin
               data_out <= rom[addr[5:0]];
		     end
        end

        // LEDs and buttons
        else begin
           // only can read buttons
           if (rw == 1'b0) begin
              case(addr)
				    'h4002: leds[7:0] <= data_in;
                'h4003: leds[15:8] <= data_in;
                'h4004: leds[23:16] <= data_in;
              endcase
           end else begin
              case(addr)
                'h4000: data_out <= {7'h0, buttons[0]};
                'h4001: data_out <= {7'h0, buttons[1]};
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
				  
	always @ * 
	begin
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

module ricoh_2a03_synth(input         CLOCK_50,
								input         cpu_nrst,
                input [3:0]   KEY,
					 input [17:1]  SW,
                output [17:0] LEDR,
					 output [7:0]  LEDG, 
					 output [6:0] HEX0,
					 output [6:0] HEX1,
					 output [6:0] HEX2,
					 output [6:0] HEX3,
					 output [6:0] HEX4,
					 output [6:0] HEX5);

   // generate clock
	reg     [31:0] clk_div;
	always @ * begin
		case(SW[3:2])
			'h3: clk_div = 14;
			'h2: clk_div = 10000;
			'h1: clk_div = 1000000;
			'h0: clk_div = 10000000;
			endcase
	end
	
   reg             CLOCK_50_div;
	reg             CLOCK_visible;
   reg     [31:0]   CLOCK_50_div_ctr;
	reg     [31:0]       CLOCK_visible_ctr;
   always @ (posedge CLOCK_50) begin
      CLOCK_50_div_ctr <= CLOCK_50_div_ctr + 'h1;
      if (CLOCK_50_div_ctr > clk_div) begin
         CLOCK_50_div_ctr <= 'h0;
         CLOCK_50_div = ~CLOCK_50_div;
      end
		
		CLOCK_visible_ctr <= CLOCK_visible_ctr + 'h1;
      if (CLOCK_visible_ctr > 'd10000000) begin
         CLOCK_visible_ctr <= 'h0;
         CLOCK_visible = ~CLOCK_visible;
      end
   end

   // hook up memory and cpu
   wire [15:0] addr;
   wire [7:0]  data_from_cpu;
   wire [7:0]  data_from_mem;
   wire rw;

	assign LEDR[16] = CLOCK_visible;
	assign LEDR[17] = rw;
	
	hexled pc_0(addr[3:0], HEX0);
	hexled pc_1(addr[7:4], HEX1);
	hexled pc_2(addr[11:8], HEX2);
	hexled pc_3(addr[15:12], HEX3);
	
	hexled dat0((1'b0) ? data_from_mem[3:0] : data_from_cpu[3:0], HEX4);
	hexled dat1((1'b0) ? data_from_mem[7:4] : data_from_cpu[7:4], HEX5);
	
   cpu_2a03 cpu(.clock(CLOCK_50_div),
                .nreset(cpu_nrst),
                .addr(addr),
                .data_out(data_from_cpu),
					 .data_in(data_from_mem),
                .rw(rw),
                .nnmi(1'b1),
                .nirq(1'b1),
                .naddr4016r(),
                .naddr4017r(),
                .addr4016w());

   peripherals p(.clock(~CLOCK_50_div),
                 .addr(addr),
                 .rw(rw),
                 .data_in(data_from_cpu),
                 .data_out(data_from_mem),
                 .buttons(KEY[1:0]),
                 .leds({LEDG, LEDR[15:0]}));
endmodule
