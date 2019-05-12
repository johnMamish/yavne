
`define MICRO_OP_INSTR_FETCH 4'b0;
`define MICRO_OP_LOAD_IDL    4'b1;

`define ALU_OP_NOP 'b0

/**
 * A lot of the instruction decoding comes from the tables at the bottom of
 * https://www.masswerk.at/6502/6502_instruction_set.html
 *
 * We refer to instructions as having 3 fields, aaabbbcc.
 */
module control_rom(input wire instr[7:0],
                   input wire cyc_count[2:0],
                   output reg uop[3:0],
                   output reg aluop[4:0]);

   wire aaa[2:0] = instr[7:5];
   wire bbb[2:0] = instr[4:2];
   wire cc[1:0]  = instr[1:0];

   always @ *
     begin
        // the first part of the instruction is always instruction fetch
        if (cyc_count == 'b0) begin
           uop = MICRO_OP_INSTR_FETCH;
           aluop = ALU_OP_NOP;
        end else begin
           // switch over "c" bits
           case(cc)
             2'b00: begin
                uop = MICRO_OP_INSTR_FETCH;
                aluop = ALU_OP_NOP;
             end

             // instructions with cc == 1 are all arithmetic instructions and all have "even"
             // addressing mode operations over bbb.
             // The only ones that are a little "odd" are LDA and STA, but we won't worry about
             // those for now.
             2'b01: begin
                // switch over address mode
                case(bbb)
                  // addr mode: x indexed, indirect
                  3'b000: begin
                     {uop, aluop} = 'h0;
                  end

                  // addr mode: zeropage
                  3'b001: begin
                     case(cyc_count)
                       'b000: {uop, aluop} =
                                             endcase
                  end

                  // addr mode: imm
                  3'b010: begin

                  end

                  // addr mode: abs
                  3'b011: begin
                  end

                  // addr mode: indirect, Y indexed
                  3'b100: begin
                  end

                  // addr mode: zeropage, X indexed
                  3'b101: begin
                  end

                  // addr mode: absolute, X indexed
                  3'b110: begin
                  end

                  // addr mode: absolute, Y indexed
                  3'b111: begin
                  end
                endcase // case (bbb)
             end

           endcase
        end // else: !if(cyc_count == 'b0)
     end  // always @*
endmodule


/**
 * cpu_2a03 is a module implementing the digital parts of the ricoh 2a03. Note that the Rout and
 * Cout analog outputs have been replaced here by digital outputs. A DAC is needed for these.
 *
 * TODO: add Rout and Cout
 *
 * @input clock     - System clock for the CPU. As far as I can tell, the original chip expects a
 *                    ~20MHz clock here which it then divides by 12, however, for now, this module
 *                    just expects 1.79-ishMHz.
 * @input nreset    - not-reset. On a low-to-high transition of this pin, the system will restart.
 *                    When this pin is held low, the system is halted in reset
 * @output addr     - system address bus.
 * @inout  data     - System data bus
 * @output rw       - direction of 6502's data bus (0=write;1=read)
 *
 */
module cpu_2a03(input clock,
                input  nreset,
                output addr[15:0],
                inout  data[7:0],
                output rw,
                input  nnmi,
                input  nirq,
                output naddr4016r,
                output naddr4017r,
                output addr4016w[2:0]);

   // internal registers
   reg PC[15:0];
   reg A[7:0];
   reg X[7:0];
   reg I[7:0];
   reg instr[7:0];
   // need some sort of "operand" register here?

   reg cyc_count[2:0];

   // current instruction + current cycle give "micro-op" control signals.
   wire micro_op[3:0];

   control_rom cr(instr, cyc_count, micro_op);


   always @ (posedge clock)
     begin
     if (nreset)
       begin
          case(micro_op)

          endcase
       end
     else
       begin
          cyc_count <= 3'b0;
          A         <= 8'b0;
          X         <= 8'b0;
          I         <= 8'b0;
       end // else: !if(nreset)
     end // always @(posedge clock)
endmodule
