
///////////////////////////////////////////////////////////////////
// Defines for internal control signals coming from control ROM
///////////////////////////////////////////////////////////////////
/////////////////// PC
// don't change the PC this cycle
`define PC_SRC_PC 3'b0
// increment the PC this cycle
`define PC_SRC_PC_PLUS1 3'b1
// something about branching
// something about ISRs


/////////////////// address bus
// put PC on address bus
`define ADDR_BUS_SRC_PC  3'b0
`define ADDR_BUS_SRC_IDL_LOW 3'b1
`define ADDR_BUS_SRC_IDL 3'b2
`define ADDR_BUS_SRC_SP 3'b3


/////////////////// A register
`define ACCUM_SRC_ACCUMHOLD 2'b0
`define ACCUM_SRC_ALU 2'b1


/////////////////// internal data latch
`define IDL_LOW_SRC_IDL_LOW  2'b0
`define IDL_LOW_SRC_DATA_BUS 2'b1

`define IDL_HI_SRC_IDL_HI    2'b0
`define IDL_HI_SRC_DATA_BUS  2'b1


/////////////////// ALU opcodes
// these decide what gets put on the output of the ALU
`define ALU_OP_OR 'b0
`define ALU_OP_AND 'b1
`define ALU_OP_EOR 'b2
`define ALU_OP_ADC 'b3


/////////////////// ALU operand2 source
`define ALU_OP2_SRC_DATA_BUS  2'b0
`define ALU_OP2_SRC_IDL_LOW   2'b1

//
`define RW_WRITE 1'b0;
`define RW_READ  1'b1;


`define CYC_COUNT_INCR  1'b0
`define CYC_COUNT_RESET 1'b1
`define CYC_COUNT_SET1  1'b2

`define CONTROL_ROM_BUNDLE  {rw, pc_src, accum_src, addr_bus_src, aluop, cyc_count_control}
`define IDL_CONTROL_BUNDLE {idl_low_src, idl_hi_src}


`ifndef NOTDEFINED
rw = RW_READ;
pc_src = PC_SRC_PC_PLUS1;
idl_low_src = IDL_LOW_SRC_IDL_LOW;
idl_hi_src = IDL_HI_SRC_IDL_HI;
accum_src = ACCUM_SRC_ACCUM;
addr_bus_src = ADDR_BUS_SRC_PC;
alu_op = ALU_OP_NOP;
alu_op2_src = ALU_OP2_SRC_DATA_BUS;
cyc_count_control = CYC_COUNT_INCR;
`endif

/**
 * A lot of the instruction decoding comes from the tables at the bottom of
 * https://www.masswerk.at/6502/6502_instruction_set.html
 *
 * We refer to instructions as having 3 fields, aaabbbcc.
 *
 * @input  instr       instruction presently being decoded
 * @input  cyc_count   cycles so far
 * @output rw          is the system bus read or written at the rising edge of the next cycle?
 * @output pc_op       describes how the PC should change at the next rising edge
 * @output addr_bus_src  what to put on the addr bus
 * @output alu_op       alu operation
 *
 */
module control_rom(input wire [7:0] instr,
                   input wire [2:0] cyc_count,
                   output reg       rw,
                   output reg [2:0] pc_src,
                   output reg [1:0] idl_low_src,
                   output reg [1:0] idl_hi_src,
                   output reg [1:0] accum_src,
                   output reg [2:0] addr_bus_src,
                   output reg [2:0] alu_op,
                   output reg [1:0] alu_op2_src,
                   output reg [1:0] cyc_count_control);

   wire aaa[2:0] = instr[7:5];
   wire bbb[2:0] = instr[4:2];
   wire cc[1:0]  = instr[1:0];

   always @ *
     begin
        // the first part of the instruction is always instruction fetch
        if (cyc_count == 'b0) begin
           rw = RW_READ;
           pc_src = PC_SRC_PC_PLUS1;
           accum_src = ACCUM_SRC_ACCUM;
           addr_bus_src = ADDR_BUS_SRC_PC;
           alu_op = ALU_OP_NOP;
           alu_op2_src = ALU_OP2_SRC_DATA_BUS;
           cyc_count_control = CYC_COUNT_INCR;
        end else begin
           // switch over "c" bits
           case(cc)
             2'b00: begin
                CONTROL_ROM_BUNDLE = 'b0;
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
                     CONTROL_ROM_BUNDLE = 'b0;
                  end

                  // addr mode: zeropage
                  3'b001: begin
                     case(cyc_count)
                       // fetch *PC from the memory and put it in IDL low
                       'b001: begin
                          rw = RW_READ;
                          pc_src = PC_SRC_PC_PLUS1;
                          idl_low_src = IDL_LOW_SRC_DATA_BUS;
                          idl_hi_src = IDL_HI_SRC_IDL_HI;
                          accum_src = ACCUM_SRC_ACCUM;
                          addr_bus_src = ADDR_BUS_SRC_PC;
                          alu_op = ALU_OP_NOP;
                          alu_op2_src = ALU_OP2_SRC_DATA_BUS;
                          cyc_count_control = CYC_COUNT_INCR;
                       end // case: 'b001

                       // route *IDL_l to ALU input and store result in accum
                       'b010: begin
                          rw = RW_READ;
                          pc_src = PC_SRC_PC;
                          IDL_CONTROL_BUNDLE = 'b0;
                          accum_src = ACCUM_SRC_ALU;
                          addr_bus_src = ADDR_BUS_SRC_IDL_LOW;
                          alu_op2_src = ALU_OP2_SRC_DATA_BUS;
                          cyc_count_control = CYC_COUNT_RESET;
                          case(aaa)
                            3'b000: alu_op = ALU_OP_OR;
                            3'b001: alu_op = ALU_OP_AND;
                            3'b010: alu_op = ALU_OP_EOR;
                            3'b011: alu_op = ALU_OP_ADC;
                            3'b111: alu_op = ALU_OP_SBC;
                            default: alu_op = 'b0;
                          endcase
                       end
                       default: begin
                          CONTROL_ROM_BUNDLE = 'b0;
                       end
                     endcase
                  end

                  // addr mode: imm
                  3'b010: begin
                     case(cyc_count)
                       // fetch the operand, put it directly into the ALU
                       'b001: begin
                          rw = RW_READ;
                          pc_src = PC_SRC_PC_PLUS1;
                          idl_low_src = IDL_LOW_SRC_IDL_LOW;
                          idl_hi_src = IDL_HI_SRC_IDL_HI;
                          accum_src = ACCUM_SRC_ACCUM;
                          addr_bus_src = ADDR_BUS_SRC_PC;
                          alu_op = ALU_OP_ADC;
                          alu_op2_src = ALU_OP2_SRC_DATA_BUS;
                          cyc_count_control = CYC_COUNT_RESET;
                       end
                     endcase
                  end

                  default: begin
                     rw = RW_READ;
                     pc_src = PC_SRC_PC_PLUS1;
                     addr_bus_src = ADDR_BUS_SRC_PC;
                     data_bus_target = DATA_BUS_INTO_ALU;
                     alu_op = ALU_OP_ADC;
                     alu_op2_src = ALU_OP2_SRC_DATA_BUS;
                     cyc_count_control = CYC_COUNT_RESET;
                  end

`ifdef NOTDEFINED
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
`endif
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

   // output data latch, TODO: need to make sure tristate works
   reg ODL[7:0];

   reg cyc_count[2:0];

   // current instruction + current cycle give "micro-op" control signals.
   wire micro_op[3:0];

   control_rom cr(instr, cyc_count, micro_op);

   // TODO: mux for address bus
   always @ *
     begin
        case(addr_bus_src)
          ADDR_BUS_SRC_PC: addr = PC;
          ADDR_BUS_SRC_IDL_LOW: addr = {8{1'b0}, IDL[7:0]};
          ADDR_BUS_SRC_IDL: addr = IDL;
          ADDR_BUS_SRC_SP: addr = {7{1'b0}, 1'b1, SP};
        endcase
     end

   always @ (posedge clock)
     begin
     if (nreset)
       begin
          // update accumulator
          case(accum_src)
            ACCUM_SRC_ACCUMHOLD: A <= A;
            ACCUM_SRC_ALU:       A <= alu_out;
          endcase

          // update
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
