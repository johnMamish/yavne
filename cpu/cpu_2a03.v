`timescale 1ns/100ps

`define DEFINED

///////////////////////////////////////////////////////////////////
// Defines for internal control signals coming from control ROM
///////////////////////////////////////////////////////////////////
/////////////////// PC
// don't change the PC this cycle
`define PC_SRC_PC 4'b0
// increment the PC this cycle
`define PC_SRC_PC_PLUS1 4'b1
// for jmp abs instructions
`define PCH_SRC_DATABUS_PCL_SRC_IDLL 4'h2

// If PCL + IDL_low has no carry, store PC <= PC+1.
// otherwise, propagate carry to PCH.
`define PC_SRC_BRANCH_CYC3 4'h4

// if a branch is taken, store PCL <= PCL + IDL_low
// else, PC <= PC+1 and load next instr
`define PC_SRC_BRANCH_ON_PLUS           4'h8
`define PC_SRC_BRANCH_ON_MINUS          4'h9
`define PC_SRC_BRANCH_ON_OVERFLOW_CLEAR 4'ha
`define PC_SRC_BRANCH_ON_OVERFLOW_SET   4'hb
`define PC_SRC_BRANCH_ON_CARRY_CLEAR    4'hc
`define PC_SRC_BRANCH_ON_CARRY_SET      4'hd
`define PC_SRC_BRANCH_ON_ZERO_CLEAR     4'he
`define PC_SRC_BRANCH_ON_ZERO_SET       4'hf

// something about ISRs



/////////////////// address bus
`define ADDR_BUS_SRC_PC  3'h0
`define ADDR_BUS_SRC_IDL_LOW 3'h1
`define ADDR_BUS_SRC_IDL 3'h2
`define ADDR_BUS_SRC_SP 3'h3


/////////////////// data bus
`define DATA_BUS_SRC_NONE 2'h0
`define DATA_BUS_SRC_ACCUM 2'h1
`define DATA_BUS_SRC_X 2'h2
`define DATA_BUS_SRC_Y 2'h3

/////////////////// instruction register
`define INSTR_REG_SRC_INSTR_REG             3'h0
`define INSTR_REG_SRC_DATA_BUS              3'h1
// if there's a branch,
`define INSTR_REG_SRC_DATA_BUS_IF_NOBRANCH  3'h2
// if PCL + 1 has no carry, loads instr reg with data bus.
`define INSTR_REG_SRC_DATA_BUS_IF_SAMEPAGE  3'h3


/////////////////// A register
`define ACCUM_SRC_ACCUM 2'b0
`define ACCUM_SRC_ALU 2'b1


/////////////////// internal data latch
`define IDL_LOW_SRC_IDL_LOW  2'b0
`define IDL_LOW_SRC_DATA_BUS 2'b1

`define IDL_HI_SRC_IDL_HI    2'b0
`define IDL_HI_SRC_DATA_BUS  2'b1

/////////////////// ALU opcodes
// these decide what gets put on the output of the ALU
`define ALU_OP_OR  4'h0
`define ALU_OP_AND 4'h1
`define ALU_OP_EOR 4'h2
`define ALU_OP_ADC 4'h3
`define ALU_OP_STA 4'h4         // sta operation: alu output don't care
`define ALU_OP_FWD_OP2 4'h5     // alu_output <= alu_op2
`define ALU_OP_CMP 4'h6
`define ALU_OP_SBC 4'h7
`define ALU_OP_NOP 4'h8
`define ALU_OP_PCL 4'h9         // PCL <= PCL + IDL
`define ALU_OP_PCH 4'ha         // PCH <= PCH + carry + idl[7] sign extend

/////////////////// ALU operand2 source
`define ALU_OP2_SRC_DATA_BUS  2'b0
`define ALU_OP2_SRC_IDL_LOW   2'b1

//
`define RW_WRITE 1'b0
`define RW_READ  1'b1


`define CYC_COUNT_INCR  3'h0
`define CYC_COUNT_RESET 3'h1
`define CYC_COUNT_SET1  3'h2
// set cycle count to 1 if branch wasn't taken.
`define CYC_COUNT_SET1_IF_NOBRANCH 3'h3
// set cycle count to 1 if PCL + 1 has no carry.
`define CYC_COUNT_SET1_IF_SAMEPAGE 3'h4


`ifdef NOTDEFINED
rw = `RW_READ;
pc_src = `PC_SRC_PC_PLUS1;
instr_reg_src = `INSTR_REG_SRC_INSTR_REG;
idl_low_src = `IDL_LOW_SRC_IDL_LOW;
idl_hi_src = `IDL_HI_SRC_IDL_HI;
accum_src = `ACCUM_SRC_ACCUM;
addr_bus_src = `ADDR_BUS_SRC_PC;
alu_op = `ALU_OP_NOP;
alu_op2_src = `ALU_OP2_SRC_DATA_BUS;
cyc_count_control = `CYC_COUNT_INCR;
`endif

/////////////////// "predefined" micro-ops
`define CONTROL_ROM_BUNDLE  {rw,            \
                             pc_src,        \
                             instr_reg_src, \
                             idl_low_src,   \
                             idl_hi_src,    \
                             accum_src,     \
                             addr_bus_src,  \
                             data_bus_src,  \
                             alu_op,        \
                             alu_op2_src,   \
                             cyc_count_control}

`define IDL_CONTROL_BUNDLE {idl_low_src, idl_hi_src}

`define UOP_IFETCH {`RW_READ,                   \
                    `PC_SRC_PC_PLUS1,           \
                    `INSTR_REG_SRC_DATA_BUS,    \
                    `IDL_LOW_SRC_IDL_LOW,       \
                    `IDL_HI_SRC_IDL_HI,         \
                    `ACCUM_SRC_ACCUM,           \
                    `ADDR_BUS_SRC_PC,           \
                    `DATA_BUS_SRC_NONE,         \
                    `ALU_OP_NOP,                \
                    `ALU_OP2_SRC_DATA_BUS,      \
                    `CYC_COUNT_INCR}

`define UOP_LOAD_IDL_LOW_FROM_PCPTR   {`RW_READ,                    \
                                       `PC_SRC_PC_PLUS1,            \
                                       `INSTR_REG_SRC_INSTR_REG,    \
                                       `IDL_LOW_SRC_DATA_BUS,       \
                                       `IDL_HI_SRC_IDL_HI,          \
                                       `ACCUM_SRC_ACCUM,            \
                                       `ADDR_BUS_SRC_PC,            \
                                       `DATA_BUS_SRC_NONE,          \
                                       `ALU_OP_NOP,                 \
                                       `ALU_OP2_SRC_DATA_BUS,       \
                                       `CYC_COUNT_INCR}

`define UOP_LOAD_IDL_HI_FROM_PCPTR    {`RW_READ,                    \
                                        `PC_SRC_PC_PLUS1,           \
                                        `INSTR_REG_SRC_INSTR_REG,   \
                                        `IDL_LOW_SRC_IDL_LOW,       \
                                        `IDL_HI_SRC_DATA_BUS,       \
                                        `ACCUM_SRC_ACCUM,           \
                                        `ADDR_BUS_SRC_PC,           \
                                        `DATA_BUS_SRC_NONE,         \
                                        `ALU_OP_NOP,                \
                                        `ALU_OP2_SRC_DATA_BUS,      \
                                        `CYC_COUNT_INCR}


`define UOP_LOAD_PC_FROM_PCPTR_IDL_LOW    {`RW_READ,                   \
                                           `PCH_SRC_DATABUS_PCL_SRC_IDLL,           \
                                           `INSTR_REG_SRC_INSTR_REG,   \
                                           `IDL_LOW_SRC_IDL_LOW,       \
                                           `IDL_HI_SRC_IDL_HI,         \
                                           `ACCUM_SRC_ACCUM,           \
                                           `ADDR_BUS_SRC_PC,           \
                                           `DATA_BUS_SRC_NONE,         \
                                           `ALU_OP_NOP,                \
                                           `ALU_OP2_SRC_DATA_BUS,      \
                                           `CYC_COUNT_RESET}

`define UOP_LOAD_IDL_INTO_PC  {`RW_READ,                  \
                                     `PC_SRC_IDL,         \
                                     `INSTR_REG_SRC_INSTR_REG,  \
                                     `IDL_LOW_SRC_IDL_LOW,      \
                                     `IDL_HI_SRC_IDL_HI,        \
                                     `ACCUM_SRC_ACCUM,          \
                                     `ADDR_BUS_SRC_IDL,         \
                                     `DATA_BUS_SRC_NONE,        \
                                     `ALU_OP_NOP,               \
                                     `ALU_OP2_SRC_DATA_BUS,     \
                                     `CYC_COUNT_INCR}

`define UOP_BRANCH_CYC2 {`RW_READ,                  \
                         `PC_SRC_BRANCH_ON_PLUS,    \
                         `INSTR_REG_SRC_DATA_BUS_IF_NOBRANCH,  \
                         `IDL_LOW_SRC_IDL_LOW,      \
                         `IDL_HI_SRC_IDL_HI,        \
                         `ACCUM_SRC_ACCUM,          \
                         `ADDR_BUS_SRC_PC,          \
                         `DATA_BUS_SRC_NONE,        \
                         `ALU_OP_PCL,               \
                         `ALU_OP2_SRC_DATA_BUS,     \
                         `CYC_COUNT_SET1_IF_NOBRANCH}

`define UOP_BRANCH_CYC3 {`RW_READ,                  \
                         `PC_SRC_BRANCH_CYC3,       \
                         `INSTR_REG_SRC_DATA_BUS_IF_SAMEPAGE, \
                         `IDL_LOW_SRC_IDL_LOW,      \
                         `IDL_HI_SRC_IDL_HI,        \
                         `ACCUM_SRC_ACCUM,          \
                         `ADDR_BUS_SRC_PC,          \
                         `DATA_BUS_SRC_NONE,        \
                         `ALU_OP_PCH,               \
                         `ALU_OP2_SRC_DATA_BUS,     \
                         `CYC_COUNT_SET1_IF_SAMEPAGE}

// TODO
`define UOP_BRANCH_CYC4 {`RW_READ,                  \
                         `PC_SRC_PC_PLUS1,       \
                         `INSTR_REG_SRC_DATA_BUS,   \
                         `IDL_LOW_SRC_IDL_LOW,      \
                         `IDL_HI_SRC_IDL_HI,        \
                         `ACCUM_SRC_ACCUM,          \
                         `ADDR_BUS_SRC_PC,          \
                         `DATA_BUS_SRC_NONE,        \
                         `ALU_OP_NOP,               \
                         `ALU_OP2_SRC_DATA_BUS,     \
                         `CYC_COUNT_SET1}


// put *PC into ALU operand2. Other things, like what the alu does with aluop2 or where the alu
// result goes, may still need to be specified outside of this macro
`define UOP_PCPTR_INTO_ALUOP2 {`RW_READ,            \
                               `PC_SRC_PC_PLUS1,    \
                               `INSTR_REG_SRC_INSTR_REG, \
                               `IDL_LOW_SRC_IDL_LOW,\
                               `IDL_HI_SRC_IDL_HI,  \
                               `ACCUM_SRC_ALU,      \
                               `ADDR_BUS_SRC_PC,    \
                               `DATA_BUS_SRC_NONE,  \
                               `ALU_OP_NOP,         \
                               `ALU_OP2_SRC_DATA_BUS,      \
                               `CYC_COUNT_RESET}


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
                   output reg [3:0] pc_src,
                   output reg [2:0] instr_reg_src,
                   output reg [1:0] idl_low_src,
                   output reg [1:0] idl_hi_src,
                   output reg [1:0] accum_src,
                   output reg [2:0] addr_bus_src,
                   output reg [1:0] data_bus_src,
                   output reg [3:0] alu_op,
                   output reg [1:0] alu_op2_src,
                   output reg [2:0] cyc_count_control);

   reg [2:0] aaa;
   reg [2:0] bbb;
   reg [1:0] cc;

   always @ *
     begin
        aaa = instr[7:5];
        bbb = instr[4:2];
        cc  = instr[1:0];

        data_bus_src = `DATA_BUS_SRC_NONE;

        // the first part of the instruction is always instruction fetch
        if (cyc_count == 'b0) begin
           `CONTROL_ROM_BUNDLE = `UOP_IFETCH;
        end else begin
           // generally, we keep the instr reg src locked.
           // only in special cases with "pipelining" will we change the instr reg on a cycle that's
           // not 0.
           instr_reg_src = `INSTR_REG_SRC_INSTR_REG;

           // switch over "c" bits
           case(cc)
             2'b00: begin
                casez({aaa, bbb})
                  // JMP abs
                   {3'h2, 3'h3}: begin
                      case(cyc_count)
                        'b001: `CONTROL_ROM_BUNDLE = `UOP_LOAD_IDL_LOW_FROM_PCPTR;
                        'b010: `CONTROL_ROM_BUNDLE = `UOP_LOAD_PC_FROM_PCPTR_IDL_LOW;
                      endcase // case (cyc_count)
                   end // case: {3'h2, 3'h3}

                  // XXX TODO JMP ind
                  {3'h3, 3'h3}: begin
                     case(cyc_count)
                       'b001: `CONTROL_ROM_BUNDLE = `UOP_LOAD_IDL_LOW_FROM_PCPTR;
                       'b010: `CONTROL_ROM_BUNDLE = `UOP_LOAD_PC_FROM_PCPTR_IDL_LOW;
                     endcase // case (cyc_count)
                  end // case: {3'h2, 3'h3}

                  // all branch instructions
                  // NB: watch out for 2's complement in branch addition
                  {3'b???, 3'h4}: begin
                     case(cyc_count)
                       'b001: `CONTROL_ROM_BUNDLE = `UOP_LOAD_IDL_LOW_FROM_PCPTR;
                       'b010: begin
                          `CONTROL_ROM_BUNDLE = `UOP_BRANCH_CYC2;
                          pc_src = {1'b1, aaa};
                       end
                       'b011: `CONTROL_ROM_BUNDLE = `UOP_BRANCH_CYC3;
                       'b100: `CONTROL_ROM_BUNDLE = `UOP_BRANCH_CYC4;
                     endcase // case (cyc_count)
                  end
                endcase
             end

             // instructions with cc == 1 are all arithmetic instructions and all have "even"
             // addressing mode operations over bbb.
             // The only ones that are a little "odd" are LDA and STA, but we won't worry about
             // those for now.
             2'b01: begin
                case(bbb)
                  // addr mode: x indexed, indirect
                  3'b000: begin
                     case (cyc_count)
                       default: begin
                          `CONTROL_ROM_BUNDLE = 'h0;
                       end
                     endcase
                  end

                  // addr mode: zeropage
                  3'b001: begin
                     case(cyc_count)
                       'b001: `CONTROL_ROM_BUNDLE = `UOP_LOAD_IDL_LOW_FROM_PCPTR;

                       // route *IDL_l to ALU input and store result in accum
                       'b010: begin
                          pc_src = `PC_SRC_PC;
                          `IDL_CONTROL_BUNDLE = 'b0;
                          addr_bus_src = `ADDR_BUS_SRC_IDL_LOW;
                          alu_op2_src = `ALU_OP2_SRC_DATA_BUS;
                          cyc_count_control = `CYC_COUNT_RESET;
                          alu_op = {1'b0, aaa};

                          // unless we are doing an STA, in which case we write the data to the bus
                          if (aaa != 'h4) begin
                             rw = `RW_READ;
                             accum_src = `ACCUM_SRC_ALU;
                          end else begin
                             rw = `RW_WRITE;
                             accum_src = `ACCUM_SRC_ACCUM;
                             data_bus_src = `DATA_BUS_SRC_ACCUM;
                          end
                       end

                       default: begin
                          `CONTROL_ROM_BUNDLE = 'b0;
                       end
                     endcase
                  end

                  // addr mode: imm
                  3'b010: begin
                     case(cyc_count)
                       // fetch the operand, put it directly into the ALU
                       'b001: begin
                          `CONTROL_ROM_BUNDLE = `UOP_PCPTR_INTO_ALUOP2;
                          alu_op = {1'b0, aaa};
                          cyc_count_control = `CYC_COUNT_RESET;
                       end
                     endcase
                  end

                  default: begin
                     `CONTROL_ROM_BUNDLE = 'b0;
                  end

                  // addr mode: abs
                  3'b011: begin
                     case(cyc_count)
                       'b001: `CONTROL_ROM_BUNDLE = `UOP_LOAD_IDL_LOW_FROM_PCPTR;
                       'b010: `CONTROL_ROM_BUNDLE = `UOP_LOAD_IDL_HI_FROM_PCPTR;

                       // do operation
                       'b011: begin
                          pc_src = `PC_SRC_PC;
                          `IDL_CONTROL_BUNDLE = 'b0;
                          addr_bus_src = `ADDR_BUS_SRC_IDL;
                          alu_op2_src = `ALU_OP2_SRC_DATA_BUS;
                          cyc_count_control = `CYC_COUNT_RESET;
                          alu_op = {1'b0, aaa};

                          // unless we are doing an STA, in which case we write the data to the bus
                          if (aaa != 'h4) begin
                             rw = `RW_READ;
                             accum_src = `ACCUM_SRC_ALU;
                          end else begin
                             rw = `RW_WRITE;
                             accum_src = `ACCUM_SRC_ACCUM;
                             data_bus_src = `DATA_BUS_SRC_ACCUM;
                          end
                       end

                       default: begin
                          `CONTROL_ROM_BUNDLE = 'b0;
                       end
                     endcase
                  end

`ifdef NOTDEFINED
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
             end // case: 2'b01

             default: begin
                `CONTROL_ROM_BUNDLE = 'b0;
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
                output reg [15:0] addr,
                inout [7:0] data,
                output rw,
                input  nnmi,
                input  nirq,
                output reg naddr4016r,
                output reg naddr4017r,
                output reg [2:0] addr4016w);

   // ======= user facing registers =======
   // program counter
   reg [15:0] PC;

   // stack pointer
   reg [7:0] SP;

   // accumulator
   reg [7:0] A;

   // index registers
   reg [7:0] X;
   reg [7:0] Y;

   reg [7:0] flags;

   //////////////// internal registers
   // current instruction
   reg [7:0] instr;

   // input data latch
   reg [15:0] IDL;

   // output data latch
   reg [7:0] ODL;
   assign data = (rw == `RW_WRITE) ? ODL : 8'hzz;
   reg [2:0] cyc_count;

   //////////////// control rom
   wire [3:0] pc_src;
   wire [2:0] instr_reg_src;
   wire [1:0] idl_low_src;
   wire [1:0] idl_hi_src;
   wire [1:0] accum_src;
   wire [2:0] addr_bus_src;
   wire [1:0] data_bus_src;
   wire [3:0] alu_op;
   wire [1:0] alu_op2_src;
   wire [2:0] cyc_count_control;
   control_rom cr(.instr(instr),
                  .cyc_count(cyc_count),
                  .rw(rw),
                  .pc_src(pc_src),
                  .instr_reg_src(instr_reg_src),
                  .idl_low_src(idl_low_src),
                  .idl_hi_src(idl_hi_src),
                  .accum_src(accum_src),
                  .addr_bus_src(addr_bus_src),
                  .data_bus_src(data_bus_src),
                  .alu_op(alu_op),
                  .alu_op2_src(alu_op2_src),
                  .cyc_count_control(cyc_count_control));

   //////////////// ALU
   // TODO: carry logic
   // TODO: flags register'
   // TODO: figure out difference between carry and overflow flags!
   // NV-BDIZC
   reg       pch_carryw;    // wire
   reg       pch_carry;     // latch latched in always @ (posedge clk) block
   reg [7:0] alu_out;
   reg [7:0] alu_op2;
   reg [7:0] alu_flags_out;
   reg [7:0] alu_flags_overwrite;
   always @ *
     begin
        case(alu_op2_src)
          `ALU_OP2_SRC_DATA_BUS: alu_op2 = data;
          `ALU_OP2_SRC_IDL_LOW:  alu_op2 = IDL[7:0];
        endcase

        alu_flags_overwrite = 'h0;
        alu_flags_out = 'h0;

        case(alu_op)
          `ALU_OP_OR:  begin
             alu_out = A | alu_op2;
             alu_flags_overwrite = 8'b1000_0010;
             alu_flags_out = {alu_out[7], 5'h0, (alu_out == 8'h00), 1'h0};
          end

          `ALU_OP_AND: begin
             alu_out = A & alu_op2;
             alu_flags_overwrite = 8'b1000_0010;
             alu_flags_out = {alu_out[7], 5'h0, (alu_out == 8'h00), 1'h0};
          end

          `ALU_OP_EOR: begin
             alu_out = A ^ alu_op2;
             alu_flags_overwrite = 8'b1000_0010;
             alu_flags_out = {alu_out[7], 5'h0, (alu_out == 8'h00), 1'h0};
          end

          `ALU_OP_ADC: begin
             //{alu_flags_out[?], alu_out} = A + alu_op2;
             alu_out = A + alu_op2;
             alu_flags_overwrite = 8'b1000_0010;
             alu_flags_out[7] = alu_out[7];
             alu_flags_out[5:0] = {4'h0, (alu_out == 8'h00), 1'h0};
          end

          `ALU_OP_STA: begin
             alu_out = 8'h0;
          end

          `ALU_OP_FWD_OP2: begin
             alu_out = alu_op2;
          end

          `ALU_OP_NOP: begin
             alu_out = 8'h00;
             alu_flags_overwrite = 8'h00;
          end

          `ALU_OP_PCL: {pch_carryw, alu_out} = PC[7:0] + IDL[7:0];
          `ALU_OP_PCH: alu_out = PC[15:8] + (pch_carry + {8{IDL[7]}});

          default: alu_out = 8'hzz;
        endcase
     end

   //////////////// mux for address bus
   always @ *
     begin
        case(addr_bus_src)
          `ADDR_BUS_SRC_PC: addr = PC;
          `ADDR_BUS_SRC_IDL_LOW: addr = {8'b0, IDL[7:0]};
          `ADDR_BUS_SRC_IDL: addr = IDL;
          `ADDR_BUS_SRC_SP: addr = {7'b0, 1'b1, SP};
        endcase
     end

   //////////////// mux for data bus
   always @ *
     begin
        ODL = 'h0;
        case(data_bus_src)
          `DATA_BUS_SRC_NONE: ODL = 8'h00;
          `DATA_BUS_SRC_ACCUM: ODL = A;
          `DATA_BUS_SRC_X: ODL = X;
          `DATA_BUS_SRC_Y: ODL = Y;
        endcase
     end

   //////////////// "do branch"? logic
   // pc_src[2:0] control which flag determines branching
   reg do_branch;
   reg do_branchp;
   always @ *
     begin
        case(pc_src[2:1])
          2'b00: do_branchp = flags[7];
          2'b01: do_branchp = flags[6];
          2'b10: do_branchp = flags[0];
          2'b11: do_branchp = flags[1];
        endcase
        do_branch = (pc_src[0]) ? (do_branchp) : (~do_branchp);
     end

   //////////////// internal logic update
   integer i = 0;
   wire    page_boundary_crossed = (pch_carry ^ IDL[7]);
   always @ (posedge clock)
     begin
     if (nreset)
       begin
          // update accumulator
          case(accum_src)
            `ACCUM_SRC_ACCUM:   A <= A;
            `ACCUM_SRC_ALU:     A <= alu_out;
          endcase

          // instruction register
          case(instr_reg_src)
            `INSTR_REG_SRC_INSTR_REG: instr <= instr;
            `INSTR_REG_SRC_DATA_BUS:  instr <= data;
            `INSTR_REG_SRC_DATA_BUS_IF_NOBRANCH: instr <= (do_branch) ? instr : data;
            `INSTR_REG_SRC_DATA_BUS_IF_SAMEPAGE: instr <= (page_boundary_crossed) ? instr : data;
          endcase

          // update internal data latch
          case(idl_low_src)
            `IDL_LOW_SRC_IDL_LOW:  IDL[7:0] <= IDL[7:0];
            `IDL_LOW_SRC_DATA_BUS: IDL[7:0] <= data[7:0];
          endcase
          case(idl_hi_src)
            `IDL_HI_SRC_IDL_HI:   IDL[15:8] <= IDL[15:8];
            `IDL_HI_SRC_DATA_BUS: IDL[15:8] <= data[7:0];
          endcase

          // update program counter
          casez(pc_src)
            `PC_SRC_PC:           PC <= PC;
            `PC_SRC_PC_PLUS1:     PC <= PC + 1;
            `PCH_SRC_DATABUS_PCL_SRC_IDLL:     PC <= {data, IDL[7:0]};

            //////// branching
            4'b1???: begin
               if (do_branch) begin
                  PC <= {PC[15:8], alu_out};
               end else begin
                  PC <= PC + 1;
               end
            end
            `PC_SRC_BRANCH_CYC3:
               if (page_boundary_crossed) begin
                  PC <= {alu_out[7:0], PC[7:0]};
               end else begin
                  PC <= PC + 1;
               end
          endcase

          // update cycle count
          case(cyc_count_control)
            `CYC_COUNT_INCR:   cyc_count <= cyc_count + 1;
            `CYC_COUNT_RESET:  cyc_count <= 'b000;
            `CYC_COUNT_SET1:   cyc_count <= 'b001;
            `CYC_COUNT_SET1_IF_NOBRANCH: cyc_count <= do_branch ? (cyc_count + 1) : 'b1;
            `CYC_COUNT_SET1_IF_SAMEPAGE: cyc_count <= (page_boundary_crossed) ? (cyc_count + 1) : 'b1;
          endcase

          pch_carry <= pch_carryw;

          // flags register
          for (i = 0; i < 8; i = i + 1) begin
             flags[i] <= alu_flags_overwrite[i] ? alu_flags_out[i] : flags[i];
          end
       end
     else
       begin
          // reset all registers
          PC        <= 'b0;
          SP        <= 'b0;
          A         <= 'b0;
          X         <= 'b0;
          Y         <= 'b0;

          pch_carry <= 'b0;
          instr     <= 'b0;
          IDL       <= 'b0;
          ODL       <= 'b0;
          cyc_count <= 'b0;
       end // else: !if(nreset)
     end // always @(posedge clock)
endmodule
