
// don't change the PC this cycle
`define PC_HOLD 3'b0
// increment the PC this cycle
`define PC_INCR 3'b1
//

// put PC on address bus
`define ADDR_BUS_PRESENT_PC  3'b0

// don't store the data on the data bus
`define DATA_BUS_IGNORE      3'b0
// store the data bus in the instruction latch
`define DATA_BUS_LATCH_INSTR 3'b1
// store the data bus in the accum latch
`define DATA_BUS_LATCH_ACCUM 3'b2
// shift the data bus into the input data latch
`define DATA_BUS_SHIFT_IN_IDL 3'b3

// ORA
`define ALU_OP_OR 'b0
// AND
`define ALU_OP_AND 'b1
// XOR
`define ALU_OP_EOR 'b2
// ADC add-carry
`define ALU_OP_ADC 'b3
// STA?
// LDA?


//
`define RW_WRITE 1'b0;
`define RW_READ  1'b1;


`define CYC_COUNT_INCR  1'b0
`define CYC_COUNT_RESET 1'b1

/**
 * A lot of the instruction decoding comes from the tables at the bottom of
 * https://www.masswerk.at/6502/6502_instruction_set.html
 *
 * We refer to instructions as having 3 fields, aaabbbcc.
 *
 * @input  instr       instruction presently being decoded
 * @input  cyc_count   cycles so far
 * @output rw          is the system bus read or written at the rising edge of the next cycle?
 * @output addr_bus_action  what to put on the addr bus
 * @output aluop       aluoperation
 *
 */
module control_rom(input wire instr[7:0],
                   input wire cyc_count[2:0],
                   output reg rw,
                   output reg addr_bus_action[2:0],
                   output reg data_bus_target[1:0],
                   output reg aluop[3:0],
                   output reg cyc_count_control);

   wire aaa[2:0] = instr[7:5];
   wire bbb[2:0] = instr[4:2];
   wire cc[1:0]  = instr[1:0];

   always @ *
     begin
        // the first part of the instruction is always instruction fetch
        if (cyc_count == 'b0) begin
           rw = RW_READ;
           addr_bus_action = ADDR_BUS_PRESENT_PC;
           data_bus_target = DATA_BUS_LATCH_INSTR;
           aluop = ALU_OP_NOP;
           cyc_count_control = CYC_COUNT_INCR;
        end else begin
           // switch over "c" bits
           case(cc)
             2'b00: begin
                rw = RW_READ;
                addr_bus_action = ADDR_BUS_PRESENT_PC;
                data_bus_target = DATA_BUS_LATCH_INSTR;
                aluop = ALU_OP_NOP;
                cyc_count_control = CYC_COUNT_INCR;
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
                     rw = RW_READ;
                     addr_bus_action = ADDR_BUS_PRESENT_PC;
                     data_bus_target = DATA_BUS_LATCH_INSTR;
                     aluop = ALU_OP_NOP;
                     cyc_count_control = CYC_COUNT_INCR;
                  end

                  // addr mode: zeropage
                  3'b001: begin
                     case(cyc_count)
                       'b001: begin
                          rw = RW_READ;
                          addr_bus_action = ADDR_BUS_PRESENT_PC;
                          data_bus_target = DATA_BUS_LATCH_INSTR;
                          aluop = ALU_OP_NOP;
                          cyc_count_control = CYC_COUNT_INCR;
                       end
                     endcase
                  end

                  // addr mode: imm
                  3'b010: begin
                     case(cyc_count)
                       // The first thing to do is to fetch the operand
                       'b001: begin
                          rw = RW_READ;
                          addr_bus_action = ADDR_BUS_PRESENT_PC;
                          data_bus_target = DATA_BUS_LATCH_INSTR;
                          aluop = ALU_OP_NOP;
                          cyc_count_control = CYC_COUNT_INCR;
                     endcase
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

   // ======= user facing registers =======
   // program counter
   reg PC[15:0];

   // stack pointer
   reg SP[7:0];

   // accumulator
   reg A[7:0];

   // index registers
   reg X[7:0];
   reg Y[7:0];

   // ======= internal registers =======
   // current instruction
   reg instr[7:0];

   // input data latch
   reg IDL[15:0];

   // output data latch, TODO: can be
   reg ODL[7:0];

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
          // reset all registers
          PC        <= 'b0;
          SP        <= 'b0;
          A         <= 'b0;
          X         <= 'b0;
          Y         <= 'b0;

          instr     <= 'b0;
          IDL       <= 'b0;
          ODL       <= 'b0;
          cyc_count <= 'b0;
       end // else: !if(nreset)
     end // always @(posedge clock)
endmodule
