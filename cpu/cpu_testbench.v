`timescale 1ns/100ps

module mem(input clock,
           input [15:0] addr,
           input        rw,
           input [7:0]  data_in,
           output reg [7:0] data_out);

   reg [7:0] memory [0:65535];

   always @ (posedge clock)
     begin
        if(rw == 1'b0) begin
           memory[addr] <= data_in;
           data_out     <= 8'b0;
        end else begin
           data_out <= memory[addr];
        end
     end
endmodule

module cpu_testbench();
   //
   wire [7:0] input_value;
   wire [7:0] bidir_signal;
   reg [7:0]  output_value;
   reg        output_value_valid;

   // hook up memory and cpu
   reg  clock;
   reg  nreset;
   wire [15:0] addr;
   wire [7:0]  bidir;
   wire [7:0]  data_from_mem;
   wire rw;

   assign bidir = (rw == 1'b0)? 8'hzz : data_from_mem;

   cpu_2a03 cpu(.clock(clock),
                .nreset(nreset),
                .addr(addr),
                .data(bidir),
                .rw(rw),
                .nnmi(1'b1),
                .nirq(1'b1),
                .naddr4016r(),
                .naddr4017r(),
                .addr4016w());

   mem memory(.clock(~clock), .addr(addr), .rw(rw), .data_in(bidir), .data_out(data_from_mem));

   // generate 1MHz clock
   reg [3:0] cyc_count_prev;
   always @ (negedge clock) begin
        cyc_count_prev <= cpu.cyc_count;
   end

   always
     begin
        #490;
        clock = ~clock;
        #10;

        if (clock && (cpu.cyc_count <= cyc_count_prev)) begin
           $display("\n");
        end
        $display("addrbus = $%h; databus = $%h; PC = $%h; A = $%h; X = %h; Y = %h; cyccount = %h; %b",
                 addr, bidir, cpu.PC, cpu.A, cpu.X, cpu.Y, cpu.cyc_count, cpu.flags);
     end

   integer i;
   initial
     begin
        // initialize memory
        for (i = 0; i <= 65536; i = i + 1)
          memory.memory[i] = 'h0;
        clock = 1'b0;
        memory.memory['h821] = 8'h31;
        memory.memory['h822] = 8'h14;

        $dumpfile("cpu_testbench.vcd");
        $dumpvars(0, cpu_testbench);


        // load machine code into memory
        $readmemh("prog.mem", memory.memory);

        // strobe reset for 3 microseconds
        nreset = 1'b0; #3000;

        // let MCU run for a bit?
        nreset = 1'b1; #250000;

        // write to memory file
        $writememh("cpu_mem_state.hex", memory.memory);
        $finish;

     end
endmodule
