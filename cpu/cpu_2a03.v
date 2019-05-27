/**
 * This code copyright James Connolly and John Mamish, 2019
 *
 *
 */


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

// signal to find errors in simulation
`define PC_SRC_LOAD_FEFE 4'h7

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
`define DATA_BUS_SRC_NONE 3'h0
`define DATA_BUS_SRC_ACCUM 3'h1
`define DATA_BUS_SRC_X 3'h2
`define DATA_BUS_SRC_Y 3'h3
`define DATA_BUS_SRC_FLAGS 3'h4
`define DATA_BUS_SRC_ALU_OUT 3'h5
`define DATA_BUS_SRC_RMWL 3'h6

/////////////////// instruction register
`define INSTR_REG_SRC_INSTR_REG             3'h0
`define INSTR_REG_SRC_DATA_BUS              3'h1
// if there's a branch,
`define INSTR_REG_SRC_DATA_BUS_IF_NOBRANCH  3'h2
// if PCL + 1 has no carry, loads instr reg with data bus.
`define INSTR_REG_SRC_DATA_BUS_IF_SAMEPAGE  3'h3


/////////////////// A register
`define ACCUM_SRC_ACCUM 2'h0
`define ACCUM_SRC_ALU 2'h1
`define ACCUM_SRC_X   2'h2
`define ACCUM_SRC_Y   2'h3


/////////////////// SP
`define SP_SRC_SP      2'h0
`define SP_SRC_ALU_OUT 2'h1
`define SP_SRC_X       2'h2


/////////////////// X register
`define X_SRC_X  2'h0
`define X_SRC_ACCUM 2'h1
`define X_SRC_ALU_OUT 2'h2
`define X_SRC_SP  2'h3


/////////////////// Y register
`define Y_SRC_Y  2'h0
`define Y_SRC_ACCUM 2'h1
`define Y_SRC_ALU_OUT 2'h2


/////////////////// flags register
`define FLAGS_SRC_NEXT 2'h0
`define FLAGS_SRC_DATA_BUS 2'h1


/////////////////// internal data latch
`define IDL_LOW_SRC_IDL_LOW  2'b0
`define IDL_LOW_SRC_DATA_BUS 2'b1
`define IDL_LOW_SRC_ALU_OUT  2'h2

`define IDL_HI_SRC_IDL_HI    2'b0
`define IDL_HI_SRC_DATA_BUS  2'b1
`define IDL_HI_SRC_IDL_HI_CARRY 2'h2   // gross hack to save on confusing alu muxing.


/////////////////// "read-modify-write" latch
`define RMWL_SRC_RMWL 2'h0
`define RMWL_SRC_DATA_BUS 2'h1


/////////////////// ALU opcodes
// these decide what gets put on the output of the ALU
`define ALU_OP_OR  5'h0
`define ALU_OP_AND 5'h1
`define ALU_OP_EOR 5'h2
`define ALU_OP_ADC 5'h3
`define ALU_OP_STA 5'h4         // sta operation: alu output don't care
`define ALU_OP_FWD_OP2 5'h5     // alu_output <= alu_op2
`define ALU_OP_CMP 5'h6
`define ALU_OP_SBC 5'h7

`define ALU_OP_BIT 5'h8

`define ALU_OP_NOP 5'h9

`define ALU_OP_PCL 5'ha         // PCL <= PCL + IDL
`define ALU_OP_PCH 5'hb         // PCH <= PCH + carry + idl[7] sign extend

`define ALU_OP_IDLL_ADD 5'hc     // IDLL <= IDLL + op2
`define ALU_OP_IDLH_CARRY 5'hd   // IDLH <= IDLH + carry

`define ALU_OP_INC 5'he     // add op1 and op2 without carry.
`define ALU_OP_INC_NOFLAGS 5'hf  // add op1 and op2 without carry and without modifying flags.

`define ALU_OP_CLC 5'h10
`define ALU_OP_SEC 5'h11
`define ALU_OP_CLV 5'h12

`define ALU_OP_ASL 5'h14
`define ALU_OP_ROL 5'h15
`define ALU_OP_LSR 5'h16
`define ALU_OP_ROR 5'h17

/////////////////// ALU operand1 source
`define ALU_OP1_SRC_A       3'h0
`define ALU_OP1_SRC_DATA    3'h1
`define ALU_OP1_SRC_X       3'h2
`define ALU_OP1_SRC_Y       3'h3
`define ALU_OP1_SRC_SP      3'h4
`define ALU_OP1_SRC_RMWL    3'h5

/////////////////// ALU operand2 source
`define ALU_OP2_SRC_DATA_BUS  3'h0
`define ALU_OP2_SRC_IDL_LOW   3'h1
`define ALU_OP2_SRC_X         3'h2
`define ALU_OP2_SRC_Y         3'h3
`define ALU_OP2_SRC_1         3'h4
`define ALU_OP2_SRC_NEG1      3'h5

// this is used for "correcting" operations which have a
`define ALU_OP2_SRC_DATA_IF_READY_ELSE_PCH 3'h4


//
`define RW_WRITE 1'b0
`define RW_READ  1'b1


//
`define RW_CONTROL_WRITE                 2'h0
`define RW_CONTROL_READ                  2'h1
`define RW_CONTROL_WRITE_WHEN_PAGE_READY 2'h2

`define CYC_COUNT_INCR  3'h0
`define CYC_COUNT_RESET 3'h1
`define CYC_COUNT_SET1  3'h2
// set cycle count to 1 if branch wasn't taken.
`define CYC_COUNT_SET1_IF_NOBRANCH 3'h3
// reset cycle count if pch_carry isn't set
`define CYC_COUNT_RESET_IF_IDX_SAMEPAGE 3'h4
`define CYC_COUNT_SET1_IF_PC_SAMEPAGE 3'h5


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
`define CONTROL_ROM_BUNDLE  {rw_control,    \
                             pc_src,        \
                             instr_reg_src, \
                             idl_low_src,   \
                             idl_hi_src,    \
                             rmwl_src,      \
                             accum_src,     \
                             sp_src,        \
                             x_src,         \
                             y_src,         \
                             flags_src,     \
                             addr_bus_src,  \
                             data_bus_src,  \
                             alu_op,        \
                             alu_op1_src,   \
                             alu_op2_src,   \
                             cyc_count_control}

`define IDL_CONTROL_BUNDLE {idl_low_src, idl_hi_src}

`define UOP_NOP {`RW_CONTROL_READ,                   \
                 `PC_SRC_PC,           \
                 `INSTR_REG_SRC_INSTR_REG,    \
                 `IDL_LOW_SRC_IDL_LOW,       \
                 `IDL_HI_SRC_IDL_HI,         \
                 `RMWL_SRC_RMWL,             \
                 `ACCUM_SRC_ACCUM,           \
                 `SP_SRC_SP,                 \
                 `X_SRC_X,                   \
                 `Y_SRC_Y,                   \
                 `FLAGS_SRC_NEXT,            \
                 `ADDR_BUS_SRC_PC,           \
                 `DATA_BUS_SRC_NONE,         \
                 `ALU_OP_NOP,                \
                 `ALU_OP1_SRC_A,             \
                 `ALU_OP2_SRC_DATA_BUS,      \
                 `CYC_COUNT_INCR}

`define UOP_IFETCH {`RW_CONTROL_READ,                   \
                    `PC_SRC_PC_PLUS1,           \
                    `INSTR_REG_SRC_DATA_BUS,    \
                    `IDL_LOW_SRC_IDL_LOW,       \
                    `IDL_HI_SRC_IDL_HI,         \
                    `RMWL_SRC_RMWL,             \
                    `ACCUM_SRC_ACCUM,           \
                    `SP_SRC_SP,                 \
                    `X_SRC_X,                   \
                    `Y_SRC_Y,                   \
                    `FLAGS_SRC_NEXT,            \
                    `ADDR_BUS_SRC_PC,           \
                    `DATA_BUS_SRC_NONE,         \
                    `ALU_OP_NOP,                \
                    `ALU_OP1_SRC_A,             \
                    `ALU_OP2_SRC_DATA_BUS,      \
                    `CYC_COUNT_INCR}

`define UOP_IFORWARD {`RW_CONTROL_READ,                   \
                      `PC_SRC_PC_PLUS1,           \
                      `INSTR_REG_SRC_DATA_BUS,    \
                      `IDL_LOW_SRC_IDL_LOW,       \
                      `IDL_HI_SRC_IDL_HI,         \
                      `RMWL_SRC_RMWL,             \
                      `ACCUM_SRC_ACCUM,           \
                      `SP_SRC_SP,                 \
                      `X_SRC_X,                   \
                      `Y_SRC_Y,                   \
                      `FLAGS_SRC_NEXT,            \
                      `ADDR_BUS_SRC_PC,           \
                      `DATA_BUS_SRC_NONE,         \
                      `ALU_OP_NOP,                \
                      `ALU_OP1_SRC_A,             \
                      `ALU_OP2_SRC_DATA_BUS,      \
                      `CYC_COUNT_SET1}

`define UOP_LOAD_IDL_LOW_FROM_PCPTR   {`RW_CONTROL_READ,                    \
                                       `PC_SRC_PC_PLUS1,            \
                                       `INSTR_REG_SRC_INSTR_REG,    \
                                       `IDL_LOW_SRC_DATA_BUS,       \
                                       `IDL_HI_SRC_IDL_HI,          \
                                       `RMWL_SRC_RMWL,             \
                                       `ACCUM_SRC_ACCUM,            \
                                       `SP_SRC_SP,                 \
                                       `X_SRC_X,                   \
                                       `Y_SRC_Y,                   \
                                       `FLAGS_SRC_NEXT,            \
                                       `ADDR_BUS_SRC_PC,            \
                                       `DATA_BUS_SRC_NONE,          \
                                       `ALU_OP_NOP,                 \
                                       `ALU_OP1_SRC_A,             \
                                       `ALU_OP2_SRC_DATA_BUS,       \
                                       `CYC_COUNT_INCR}

`define UOP_LOAD_IDL_HI_FROM_PCPTR    {`RW_CONTROL_READ,                    \
                                        `PC_SRC_PC_PLUS1,           \
                                        `INSTR_REG_SRC_INSTR_REG,   \
                                        `IDL_LOW_SRC_IDL_LOW,       \
                                        `IDL_HI_SRC_DATA_BUS,       \
                                       `RMWL_SRC_RMWL,             \
                                        `ACCUM_SRC_ACCUM,           \
                                       `SP_SRC_SP,                 \
                                       `X_SRC_X,                   \
                                       `Y_SRC_Y,                   \
                                       `FLAGS_SRC_NEXT,            \
                                        `ADDR_BUS_SRC_PC,           \
                                        `DATA_BUS_SRC_NONE,         \
                                        `ALU_OP_NOP,                \
                                       `ALU_OP1_SRC_A,             \
                                        `ALU_OP2_SRC_DATA_BUS,      \
                                        `CYC_COUNT_INCR}


`define UOP_LOAD_PC_FROM_PCPTR_IDL_LOW    {`RW_CONTROL_READ,                   \
                                           `PCH_SRC_DATABUS_PCL_SRC_IDLL,           \
                                           `INSTR_REG_SRC_INSTR_REG,   \
                                           `IDL_LOW_SRC_IDL_LOW,       \
                                           `IDL_HI_SRC_IDL_HI,         \
                                           `RMWL_SRC_RMWL,             \
                                           `ACCUM_SRC_ACCUM,           \
                                           `SP_SRC_SP,                 \
                                           `X_SRC_X,                   \
                                           `Y_SRC_Y,                   \
                                           `FLAGS_SRC_NEXT,            \
                                           `ADDR_BUS_SRC_PC,           \
                                           `DATA_BUS_SRC_NONE,         \
                                           `ALU_OP_NOP,                \
                                           `ALU_OP1_SRC_A,             \
                                           `ALU_OP2_SRC_DATA_BUS,      \
                                           `CYC_COUNT_RESET}

`define UOP_LOAD_IDL_INTO_PC  {`RW_CONTROL_READ,                  \
                               `PC_SRC_IDL,         \
                               `INSTR_REG_SRC_INSTR_REG,  \
                               `IDL_LOW_SRC_IDL_LOW,      \
                               `IDL_HI_SRC_IDL_HI,        \
                               `RMWL_SRC_RMWL,             \
                               `ACCUM_SRC_ACCUM,          \
                               `SP_SRC_SP,                 \
                               `X_SRC_X,                   \
                               `Y_SRC_Y,                   \
                               `FLAGS_SRC_NEXT,            \
                               `ADDR_BUS_SRC_IDL,         \
                               `DATA_BUS_SRC_NONE,        \
                               `ALU_OP_NOP,               \
                               `ALU_OP1_SRC_A,             \
                               `ALU_OP2_SRC_DATA_BUS,     \
                               `CYC_COUNT_INCR}

`define UOP_BRANCH_CYC2 {`RW_CONTROL_READ,                  \
                         `PC_SRC_BRANCH_ON_PLUS,    \
                         `INSTR_REG_SRC_DATA_BUS_IF_NOBRANCH,  \
                         `IDL_LOW_SRC_IDL_LOW,      \
                         `IDL_HI_SRC_IDL_HI,        \
                         `RMWL_SRC_RMWL,             \
                         `ACCUM_SRC_ACCUM,          \
                         `SP_SRC_SP,                 \
                         `X_SRC_X,                   \
                         `Y_SRC_Y,                   \
                         `FLAGS_SRC_NEXT,            \
                         `ADDR_BUS_SRC_PC,          \
                         `DATA_BUS_SRC_NONE,        \
                         `ALU_OP_PCL,               \
                         `ALU_OP1_SRC_A,             \
                         `ALU_OP2_SRC_DATA_BUS,     \
                         `CYC_COUNT_SET1_IF_NOBRANCH}

`define UOP_BRANCH_CYC3 {`RW_CONTROL_READ,                  \
                         `PC_SRC_BRANCH_CYC3,       \
                         `INSTR_REG_SRC_DATA_BUS_IF_SAMEPAGE, \
                         `IDL_LOW_SRC_IDL_LOW,      \
                         `IDL_HI_SRC_IDL_HI,        \
                         `RMWL_SRC_RMWL,             \
                         `ACCUM_SRC_ACCUM,          \
                         `SP_SRC_SP,                 \
                         `X_SRC_X,                   \
                         `Y_SRC_Y,                   \
                         `FLAGS_SRC_NEXT,            \
                         `ADDR_BUS_SRC_PC,          \
                         `DATA_BUS_SRC_NONE,        \
                         `ALU_OP_PCH,               \
                         `ALU_OP1_SRC_A,             \
                         `ALU_OP2_SRC_DATA_BUS,     \
                         `CYC_COUNT_SET1_IF_PC_SAMEPAGE}


`define UOP_BRANCH_CYC4 {`RW_CONTROL_READ,                  \
                         `PC_SRC_PC_PLUS1,       \
                         `INSTR_REG_SRC_DATA_BUS,   \
                         `IDL_LOW_SRC_IDL_LOW,      \
                         `IDL_HI_SRC_IDL_HI,        \
                         `RMWL_SRC_RMWL,             \
                         `ACCUM_SRC_ACCUM,          \
                         `SP_SRC_SP,                 \
                         `X_SRC_X,                   \
                         `Y_SRC_Y,                   \
                         `FLAGS_SRC_NEXT,            \
                         `ADDR_BUS_SRC_PC,          \
                         `DATA_BUS_SRC_NONE,        \
                         `ALU_OP_NOP,               \
                         `ALU_OP1_SRC_A,             \
                         `ALU_OP2_SRC_DATA_BUS,     \
                         `CYC_COUNT_SET1}


// put *PC into ALU operand2. Other things, like what the alu does with aluop2 or where the alu
// result goes, may still need to be specified outside of this macro
`define UOP_PCPTR_INTO_ALUOP2 {`RW_CONTROL_READ,            \
                               `PC_SRC_PC_PLUS1,    \
                               `INSTR_REG_SRC_INSTR_REG, \
                               `IDL_LOW_SRC_IDL_LOW,\
                               `IDL_HI_SRC_IDL_HI,  \
                               `RMWL_SRC_RMWL,             \
                               `ACCUM_SRC_ALU,      \
                               `SP_SRC_SP,                 \
                               `X_SRC_X,                   \
                               `Y_SRC_Y,                   \
                               `FLAGS_SRC_NEXT,            \
                               `ADDR_BUS_SRC_PC,    \
                               `DATA_BUS_SRC_NONE,  \
                               `ALU_OP_NOP,         \
                               `ALU_OP1_SRC_A,             \
                               `ALU_OP2_SRC_DATA_BUS,      \
                               `CYC_COUNT_RESET}

`define UOP_ALUOP_ACCUM_DATABUS {`RW_CONTROL_READ,               \
                                 `PC_SRC_PC_PLUS1,    \
                                 `INSTR_REG_SRC_INSTR_REG, \
                                 `IDL_LOW_SRC_IDL_LOW,\
                                 `IDL_HI_SRC_IDL_HI,  \
                                 `RMWL_SRC_RMWL,             \
                                 `ACCUM_SRC_ALU,      \
                                 `SP_SRC_SP,                 \
                                 `X_SRC_X,                   \
                                 `Y_SRC_Y,                   \
                                 `FLAGS_SRC_NEXT,            \
                                 `ADDR_BUS_SRC_PC,    \
                                 `DATA_BUS_SRC_NONE,  \
                                 `ALU_OP_NOP,         \
                                 `ALU_OP1_SRC_A,             \
                                 `ALU_OP2_SRC_DATA_BUS,      \
                                 `CYC_COUNT_RESET}

`define UOP_ALUOP_ADD_IDL {`RW_CONTROL_READ,                   \
                           `PC_SRC_PC,                 \
                           `INSTR_REG_SRC_INSTR_REG,   \
                           `IDL_LOW_SRC_ALU_OUT,       \
                           `IDL_HI_SRC_IDL_HI,         \
                           `RMWL_SRC_RMWL,             \
                           `ACCUM_SRC_ACCUM,           \
                           `SP_SRC_SP,                 \
                           `X_SRC_X,                   \
                           `Y_SRC_Y,                   \
                           `FLAGS_SRC_NEXT,            \
                           `ADDR_BUS_SRC_PC,           \
                           `DATA_BUS_SRC_NONE,         \
                           `ALU_OP_IDLL_ADD,                \
                           `ALU_OP1_SRC_A,             \
                           `ALU_OP2_SRC_DATA_BUS,      \
                           `CYC_COUNT_INCR}

`define UOP_LOAD_RMWL {`RW_CONTROL_READ,           \
                       `PC_SRC_PC,                 \
                       `INSTR_REG_SRC_INSTR_REG,   \
                       `IDL_LOW_SRC_IDL_LOW,       \
                       `IDL_HI_SRC_IDL_HI,         \
                       `RMWL_SRC_DATA_BUS,         \
                       `ACCUM_SRC_ACCUM,           \
                       `SP_SRC_SP,                 \
                       `X_SRC_X,                   \
                       `Y_SRC_Y,                   \
                       `FLAGS_SRC_NEXT,            \
                       `ADDR_BUS_SRC_IDL,          \
                       `DATA_BUS_SRC_NONE,         \
                       `ALU_OP_NOP,                \
                       `ALU_OP1_SRC_A,             \
                       `ALU_OP2_SRC_DATA_BUS,      \
                       `CYC_COUNT_INCR}

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
                   output reg [1:0] rw_control,
                   output reg [3:0] pc_src,
                   output reg [2:0] instr_reg_src,
                   output reg [1:0] idl_low_src,
                   output reg [1:0] idl_hi_src,
                   output reg [1:0] rmwl_src,
                   output reg [1:0] accum_src,
                   output reg [1:0] sp_src,
                   output reg [1:0] x_src,
                   output reg [1:0] y_src,
                   output reg [1:0] flags_src,
                   output reg [2:0] addr_bus_src,
                   output reg [2:0] data_bus_src,
                   output reg [4:0] alu_op,
                   output reg [2:0] alu_op1_src,
                   output reg [2:0] alu_op2_src,
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
           rw_control = `RW_CONTROL_READ;
           $display("cyc count is 0. rw_control is %b", rw_control);
        end else begin
           // generally, we keep the instr reg src locked.
           // only in special cases with "pipelining" will we change the instr reg on a cycle that's
           // not 0.
           instr_reg_src = `INSTR_REG_SRC_INSTR_REG;

           // switch over "c" bits
           case(cc)
             2'b00: begin
                casez({aaa, bbb})
                  // PHP, PHA
                  {3'b0?0, 3'h2}: begin
                     case(cyc_count)
                       'b001: begin
                          `CONTROL_ROM_BUNDLE = `UOP_NOP;
                          addr_bus_src = `ADDR_BUS_SRC_SP;
                          rw_control = `RW_CONTROL_WRITE;
                          data_bus_src = (aaa[1] == 'b1)?`DATA_BUS_SRC_ACCUM:`DATA_BUS_SRC_FLAGS;
                       end
                       'b010: begin
                          `CONTROL_ROM_BUNDLE = `UOP_NOP;
                          alu_op = `ALU_OP_INC_NOFLAGS;
                          alu_op1_src = `ALU_OP1_SRC_SP;
                          alu_op2_src = `ALU_OP2_SRC_NEG1;
                          sp_src = `SP_SRC_ALU_OUT;
                          cyc_count_control = `CYC_COUNT_RESET;
                       end
                     endcase
                  end // case: {3'b0??, 3'h2}

                  // BIT
                  {3'b001, 3'b0?1}: begin
                     case(cyc_count)
                       'b001: `CONTROL_ROM_BUNDLE = `UOP_LOAD_IDL_LOW_FROM_PCPTR;
                       'b010: begin
                          if (bbb == 3'b011) begin
                             `CONTROL_ROM_BUNDLE = `UOP_LOAD_IDL_HI_FROM_PCPTR;
                          end else begin
                             // route *IDL_l to ALU input
                             `CONTROL_ROM_BUNDLE = `UOP_NOP;
                             alu_op = `ALU_OP_BIT;
                             addr_bus_src = `ADDR_BUS_SRC_IDL_LOW;
                             alu_op2_src = `ALU_OP2_SRC_DATA_BUS;
                             cyc_count_control = `CYC_COUNT_RESET;
                          end
                       end // case: 'b010
                       'b011: begin
                          `CONTROL_ROM_BUNDLE = `UOP_NOP;
                          alu_op = `ALU_OP_BIT;
                          addr_bus_src = `ADDR_BUS_SRC_IDL;
                          alu_op2_src = `ALU_OP2_SRC_DATA_BUS;
                          cyc_count_control = `CYC_COUNT_RESET;
                       end
                     endcase
                  end

                  // PLP, PLA
                  {3'b0?1, 3'h2}: begin
                     case(cyc_count)
                       // https://github.com/eteran/pretendo/blob/master/doc/cpu/6502.txt
                       // says that on cycle 1, PLP and PLA practically do nothing.
                       'b001: `CONTROL_ROM_BUNDLE = `UOP_NOP;
                       'b010: begin
                          `CONTROL_ROM_BUNDLE = `UOP_NOP;
                          alu_op = `ALU_OP_INC_NOFLAGS;
                          alu_op1_src = `ALU_OP1_SRC_SP;
                          alu_op2_src = `ALU_OP2_SRC_1;
                          sp_src = `SP_SRC_ALU_OUT;
                          cyc_count_control = `CYC_COUNT_INCR;
                       end
                       'b011: begin
                          `CONTROL_ROM_BUNDLE = `UOP_NOP;
                          addr_bus_src = `ADDR_BUS_SRC_SP;
                          cyc_count_control = `CYC_COUNT_RESET;
                          if (aaa[1] == 1'b0) begin
                             flags_src = `FLAGS_SRC_DATA_BUS;
                          end else begin
                             alu_op = `ALU_OP_FWD_OP2;
                             alu_op2_src = `ALU_OP2_SRC_DATA_BUS;
                             accum_src = `ACCUM_SRC_ALU;
                          end
                       end
                     endcase // case (cyc_count)
                  end

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
                  end // case: {3'b???, 3'h4}

                  // TAY, TYA
                  {3'h4, 3'h6}, {3'h5, 3'h2}: begin
                     `CONTROL_ROM_BUNDLE = `UOP_NOP;
                     cyc_count_control = `CYC_COUNT_RESET;
                     if ({aaa, bbb} == {3'h4, 3'h6})
                       accum_src = `ACCUM_SRC_Y;
                     else
                       y_src = `Y_SRC_ACCUM;
                  end

                  // LDY #
                  {3'b101, 3'h0}: begin
                     `CONTROL_ROM_BUNDLE = `UOP_PCPTR_INTO_ALUOP2;
                     accum_src = `ACCUM_SRC_ACCUM;
                     y_src = `Y_SRC_ALU_OUT;
                     alu_op = `ALU_OP_FWD_OP2;
                     cyc_count_control = `CYC_COUNT_RESET;
                  end

                  // {CPX, CPY} #
                  {3'b11?, 3'h0}: begin
                     `CONTROL_ROM_BUNDLE = `UOP_PCPTR_INTO_ALUOP2;
                     accum_src = `ACCUM_SRC_ACCUM;
                     alu_op = `ALU_OP_CMP;
                     alu_op1_src = (aaa[0] == 1'b0) ? `ALU_OP1_SRC_Y : `ALU_OP1_SRC_X;
                     cyc_count_control = `CYC_COUNT_RESET;
                  end

                  // {STY, LDY} zpg
                  {3'b10?, 3'h1}: begin
                     case(cyc_count)
                       'b001: `CONTROL_ROM_BUNDLE = `UOP_LOAD_IDL_LOW_FROM_PCPTR;
                       'b010: begin
                          `CONTROL_ROM_BUNDLE = `UOP_NOP;
                          addr_bus_src = `ADDR_BUS_SRC_IDL_LOW;
                          cyc_count_control = `CYC_COUNT_RESET;
                          if (aaa == 3'b100) begin
                             rw_control = `RW_CONTROL_WRITE;
                             data_bus_src = `DATA_BUS_SRC_Y;
                          end else begin
                             rw_control = `RW_CONTROL_READ;
                             alu_op2_src = `ALU_OP2_SRC_DATA_BUS;
                             alu_op = `ALU_OP_FWD_OP2;
                             y_src = `Y_SRC_ALU_OUT;
                          end
                       end // case: 'b010
                     endcase
                  end

                  // {STY, LDY} abs
                  {3'b10?, 3'h3}: begin
                     case(cyc_count)
                       'b001: `CONTROL_ROM_BUNDLE = `UOP_LOAD_IDL_LOW_FROM_PCPTR;
                       'b010: `CONTROL_ROM_BUNDLE = `UOP_LOAD_IDL_HI_FROM_PCPTR;
                       'b011: begin
                          `CONTROL_ROM_BUNDLE = `UOP_NOP;
                          addr_bus_src = `ADDR_BUS_SRC_IDL;
                          cyc_count_control = `CYC_COUNT_RESET;
                          if (aaa == 3'b100) begin
                             rw_control = `RW_CONTROL_WRITE;
                             data_bus_src = `DATA_BUS_SRC_Y;
                          end else begin
                             rw_control = `RW_CONTROL_READ;
                             alu_op2_src = `ALU_OP2_SRC_DATA_BUS;
                             alu_op = `ALU_OP_FWD_OP2;
                             y_src = `Y_SRC_ALU_OUT;
                          end
                       end
                     endcase // case (cyc_count)
                  end

                  // {STY, LDY} zpg, X
                  {3'b10?, 3'h5}: begin
                     case(cyc_count)
                       'b001: `CONTROL_ROM_BUNDLE = `UOP_LOAD_IDL_LOW_FROM_PCPTR;
                       // IDL_low <= X + IDL_low
                       'b010: begin
                          `CONTROL_ROM_BUNDLE = `UOP_ALUOP_ADD_IDL;
                          alu_op2_src = `ALU_OP2_SRC_X;
                       end
                       'b011: begin
                          `CONTROL_ROM_BUNDLE = `UOP_NOP;
                          addr_bus_src = `ADDR_BUS_SRC_IDL_LOW;
                          cyc_count_control = `CYC_COUNT_RESET;
                          if (aaa == 3'b100) begin
                             rw_control = `RW_CONTROL_WRITE;
                             data_bus_src = `DATA_BUS_SRC_Y;
                          end else begin
                             rw_control = `RW_CONTROL_READ;
                             alu_op2_src = `ALU_OP2_SRC_DATA_BUS;
                             alu_op = `ALU_OP_FWD_OP2;
                             y_src = `Y_SRC_ALU_OUT;
                          end
                       end
                     endcase // case (cyc_count)
                  end

                  // DEY, INY
                  {3'h6, 3'h2}, {3'h4, 3'h2}: begin
                     `CONTROL_ROM_BUNDLE = `UOP_NOP;
                     alu_op = `ALU_OP_INC;
                     alu_op1_src = `ALU_OP1_SRC_Y;
                     alu_op2_src = (aaa == 3'h6) ? `ALU_OP2_SRC_1 : `ALU_OP2_SRC_NEG1;
                     y_src = `Y_SRC_ALU_OUT;
                     cyc_count_control = `CYC_COUNT_RESET;
                  end

                  // INX
                  {3'h7, 3'h2}: begin
                     `CONTROL_ROM_BUNDLE = `UOP_NOP;
                     alu_op = `ALU_OP_INC;
                     alu_op1_src = `ALU_OP1_SRC_X;
                     alu_op2_src = `ALU_OP2_SRC_1;
                     x_src = `X_SRC_ALU_OUT;
                     cyc_count_control = `CYC_COUNT_RESET;
                  end

                  // CLC
                  {3'h0, 3'h6}: begin
                     `CONTROL_ROM_BUNDLE = `UOP_NOP;
                     cyc_count_control = `CYC_COUNT_RESET;
                     alu_op = `ALU_OP_CLC;
                  end

                  // SEC
                  {3'h1, 3'h6}: begin
                     `CONTROL_ROM_BUNDLE = `UOP_NOP;
                     cyc_count_control = `CYC_COUNT_RESET;
                     alu_op = `ALU_OP_SEC;
                  end

                  // CLV
                  {3'h0, 3'h6}: begin
                     `CONTROL_ROM_BUNDLE = `UOP_NOP;
                     cyc_count_control = `CYC_COUNT_RESET;
                     alu_op = `ALU_OP_CLV;
                  end
                endcase
             end

             // instructions with cc == 1 are all arithmetic instructions and all have "even"
             // addressing mode operations over bbb.
             // The only ones that are a little "odd" are LDA and STA, but we won't worry about
             // those for now.
             2'b01: begin
                casez(bbb)
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
                             rw_control = `RW_CONTROL_READ;
                             accum_src = `ACCUM_SRC_ALU;
                          end else begin
                             rw_control = `RW_CONTROL_WRITE;
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
                             rw_control = `RW_CONTROL_READ;
                             accum_src = `ACCUM_SRC_ALU;
                          end else begin
                             rw_control = `RW_CONTROL_WRITE;
                             accum_src = `ACCUM_SRC_ACCUM;
                             data_bus_src = `DATA_BUS_SRC_ACCUM;
                          end
                       end

                       default: begin
                          `CONTROL_ROM_BUNDLE = 'b0;
                       end
                     endcase
                  end

                  // addr mode: indirect, Y indexed
                  3'b100: begin
                     `CONTROL_ROM_BUNDLE = 'hf00fba11;
                  end

                  // addr mode: zeropage, X indexed
                  3'b101: begin
                     case(cyc_count)
                       'b001: `CONTROL_ROM_BUNDLE = `UOP_LOAD_IDL_LOW_FROM_PCPTR;
                       // IDL_low <= X + IDL_low
                       'b010: begin
                          `CONTROL_ROM_BUNDLE = `UOP_ALUOP_ADD_IDL;
                          alu_op2_src = `ALU_OP2_SRC_X;
                       end
                       'b011: begin
                          `CONTROL_ROM_BUNDLE = `UOP_ALUOP_ACCUM_DATABUS;
                          pc_src = `PC_SRC_PC;
                          addr_bus_src = `ADDR_BUS_SRC_IDL_LOW;
                          alu_op = {1'b0, aaa};

                          if (aaa == 'h4) begin
                             rw_control = `RW_CONTROL_WRITE;
                             accum_src = `ACCUM_SRC_ACCUM;
                             data_bus_src = `DATA_BUS_SRC_ACCUM;
                          end
                       end
                     endcase
                  end

                  // addr mode: absolute, X or Y indexed
                  // note: no sign extension required, just carry.
                  3'b11?: begin
                     case(cyc_count)
                       'b001: `CONTROL_ROM_BUNDLE = `UOP_LOAD_IDL_LOW_FROM_PCPTR;

                       // IDLL <= X,Y + IDLL; IDLH <= *PC
                       'b010: begin
                          `CONTROL_ROM_BUNDLE = `UOP_LOAD_IDL_HI_FROM_PCPTR;
                          idl_low_src = `IDL_LOW_SRC_ALU_OUT;
                          alu_op      = `ALU_OP_IDLL_ADD;
                          alu_op2_src = (bbb[0]) ? (`ALU_OP2_SRC_X) : (`ALU_OP2_SRC_Y);
                       end

                       'b011: begin
                          `CONTROL_ROM_BUNDLE = `UOP_ALUOP_ACCUM_DATABUS;
                          pc_src = `PC_SRC_PC;
                          idl_hi_src = `IDL_HI_SRC_IDL_HI_CARRY;
                          addr_bus_src = `ADDR_BUS_SRC_IDL;
                          alu_op2_src = `ALU_OP2_SRC_DATA_BUS;
                          cyc_count_control = `CYC_COUNT_RESET_IF_IDX_SAMEPAGE;
                          alu_op = {1'b0, aaa};
                          if (aaa == 'h4) begin
                             rw_control = `RW_CONTROL_WRITE_WHEN_PAGE_READY;
                             accum_src = `ACCUM_SRC_ACCUM;
                             data_bus_src = `DATA_BUS_SRC_ACCUM;
                          end
                       end

                       // the problem is that aluop2 depends on whether there was a carry or not
                       // addrbus = IDL
                       // if no carry
                       //    A <= A op databus
                       //
                       // IDLH <= carry + IDLH
                       'b100: begin
                          `CONTROL_ROM_BUNDLE = `UOP_ALUOP_ACCUM_DATABUS;
                          pc_src = `PC_SRC_PC;
                          addr_bus_src = `ADDR_BUS_SRC_IDL;
                          alu_op2_src = `ALU_OP2_SRC_DATA_BUS;
                          cyc_count_control = `CYC_COUNT_RESET;
                          alu_op = {1'b0, aaa};
                          if (aaa == 'h4) begin
                             rw_control = `RW_CONTROL_WRITE;
                             accum_src = `ACCUM_SRC_ACCUM;
                             data_bus_src = `DATA_BUS_SRC_ACCUM;
                          end
                       end
                     endcase // case (cyc_count)
                  end
                endcase // case (bbb)
             end // case: 2'b01

             2'b10: begin
                casez({aaa, bbb})
                  // TXA and TAX; "pipelined"
                  {3'b10?, 3'h2}: begin
                     `CONTROL_ROM_BUNDLE = `UOP_IFORWARD;
                     if (aaa[0]) begin
                       x_src = `X_SRC_ACCUM;
                     end else begin
                       accum_src = `ACCUM_SRC_X;
                     end
                  end

                  // DEX
                  {3'h6, 3'h2}: begin
                     `CONTROL_ROM_BUNDLE = `UOP_NOP;
                     alu_op = `ALU_OP_INC;
                     alu_op1_src = `ALU_OP1_SRC_X;
                     alu_op2_src = `ALU_OP2_SRC_NEG1;
                     x_src = `X_SRC_ALU_OUT;
                  end

                  // NOP
                  {3'h7, 3'h2}: begin
                     `CONTROL_ROM_BUNDLE = `UOP_NOP;
                     cyc_count_control = `CYC_COUNT_RESET;
                  end

                  // LDX #
                  {3'b101, 3'h0}: begin
                     `CONTROL_ROM_BUNDLE = `UOP_PCPTR_INTO_ALUOP2;
                     accum_src = `ACCUM_SRC_ACCUM;
                     x_src = `X_SRC_ALU_OUT;
                     alu_op = `ALU_OP_FWD_OP2;
                     cyc_count_control = `CYC_COUNT_RESET;
                  end

                  // {STX, LDX} zpg
                  {3'b10?, 3'h1}: begin
                     case(cyc_count)
                       'b001: `CONTROL_ROM_BUNDLE = `UOP_LOAD_IDL_LOW_FROM_PCPTR;
                       'b010: begin
                          `CONTROL_ROM_BUNDLE = `UOP_NOP;
                          addr_bus_src = `ADDR_BUS_SRC_IDL_LOW;
                          cyc_count_control = `CYC_COUNT_RESET;
                          if (aaa == 3'b100) begin
                             rw_control = `RW_CONTROL_WRITE;
                             data_bus_src = `DATA_BUS_SRC_X;
                          end else begin
                             rw_control = `RW_CONTROL_READ;
                             alu_op2_src = `ALU_OP2_SRC_DATA_BUS;
                             alu_op = `ALU_OP_FWD_OP2;
                             x_src = `X_SRC_ALU_OUT;
                          end
                       end // case: 'b010
                     endcase
                  end

                  // {STX, LDX} zpg, Y
                  {3'b10?, 3'h5}: begin
                     case(cyc_count)
                       'b001: `CONTROL_ROM_BUNDLE = `UOP_LOAD_IDL_LOW_FROM_PCPTR;
                       // IDL_low <= Y + IDL_low
                       'b010: begin
                          `CONTROL_ROM_BUNDLE = `UOP_ALUOP_ADD_IDL;
                          alu_op2_src = `ALU_OP2_SRC_Y;
                       end
                       'b011: begin
                          `CONTROL_ROM_BUNDLE = `UOP_NOP;
                          addr_bus_src = `ADDR_BUS_SRC_IDL_LOW;
                          cyc_count_control = `CYC_COUNT_RESET;
                          if (aaa == 3'b100) begin
                             rw_control = `RW_CONTROL_WRITE;
                             data_bus_src = `DATA_BUS_SRC_X;
                          end else begin
                             rw_control = `RW_CONTROL_READ;
                             alu_op2_src = `ALU_OP2_SRC_DATA_BUS;
                             alu_op = `ALU_OP_FWD_OP2;
                             x_src = `X_SRC_ALU_OUT;
                          end
                       end
                     endcase // case (cyc_count)
                  end // case: {3'b10?, 3'h5}

                  // DEC, INC zeropage
                  {3'b11?, 3'h1}: begin
                     case(cyc_count)
                       'b001: `CONTROL_ROM_BUNDLE = `UOP_LOAD_IDL_LOW_FROM_PCPTR;
                     endcase
                  end

                  // {STX, LDX} abs
                  {3'b10?, 3'h3}: begin
                     case(cyc_count)
                       'b001: `CONTROL_ROM_BUNDLE = `UOP_LOAD_IDL_LOW_FROM_PCPTR;
                       'b010: `CONTROL_ROM_BUNDLE = `UOP_LOAD_IDL_HI_FROM_PCPTR;
                       'b011: begin
                          `CONTROL_ROM_BUNDLE = `UOP_NOP;
                          addr_bus_src = `ADDR_BUS_SRC_IDL;
                          cyc_count_control = `CYC_COUNT_RESET;
                          if (aaa == 3'b100) begin
                             rw_control = `RW_CONTROL_WRITE;
                             data_bus_src = `DATA_BUS_SRC_X;
                          end else begin
                             rw_control = `RW_CONTROL_READ;
                             alu_op2_src = `ALU_OP2_SRC_DATA_BUS;
                             alu_op = `ALU_OP_FWD_OP2;
                             x_src = `X_SRC_ALU_OUT;
                          end
                       end // case: 'b010
                     endcase
                  end // case: {3'b10?, 3'h3}

                  {3'b10?, 3'b110}: begin
                     `CONTROL_ROM_BUNDLE = `UOP_NOP;
                     cyc_count_control = `CYC_COUNT_RESET;
                     if (aaa[0] == 1'b0) begin
                        sp_src = `SP_SRC_X;
                     end else begin
                        x_src = `X_SRC_SP;
                     end
                  end

                  //////////////// rotate zpg
                  {3'b0??, 3'b001}: begin
                     case(cyc_count)
                       'b001: `CONTROL_ROM_BUNDLE = `UOP_LOAD_IDL_LOW_FROM_PCPTR;
                       'b010: begin
                          `CONTROL_ROM_BUNDLE = `UOP_LOAD_RMWL;
                          addr_bus_src = `ADDR_BUS_SRC_IDL_LOW;
                       end
                       'b011: begin
                          // this cycle is basically a nop
                          `CONTROL_ROM_BUNDLE = `UOP_NOP;
                          rw_control = `RW_CONTROL_WRITE;
                          addr_bus_src = `ADDR_BUS_SRC_IDL_LOW;
                          data_bus_src = `DATA_BUS_SRC_RMWL;
                       end
                       'b100: begin
                          `CONTROL_ROM_BUNDLE = `UOP_NOP;
                          alu_op = {3'b101, aaa[1:0]};
                          alu_op1_src = `ALU_OP1_SRC_RMWL;
                          rw_control = `RW_CONTROL_WRITE;
                          addr_bus_src = `ADDR_BUS_SRC_IDL_LOW;
                          data_bus_src = `DATA_BUS_SRC_ALU_OUT;
                          cyc_count_control = `CYC_COUNT_RESET;
                       end
                     endcase
                  end // case: {3'b0??, 3'b001}

                  //////////////// rotate abs
                  {3'b0??, 3'b011}: begin
                     case(cyc_count)
                       'b001: `CONTROL_ROM_BUNDLE = `UOP_LOAD_IDL_LOW_FROM_PCPTR;
                       'b010: `CONTROL_ROM_BUNDLE = `UOP_LOAD_IDL_HI_FROM_PCPTR;
                       'b011: begin
                          `CONTROL_ROM_BUNDLE = `UOP_LOAD_RMWL;
                          addr_bus_src = `ADDR_BUS_SRC_IDL;
                       end
                       'b100: begin
                          // this cycle is basically a nop
                          `CONTROL_ROM_BUNDLE = `UOP_NOP;
                          rw_control = `RW_CONTROL_WRITE;
                          addr_bus_src = `ADDR_BUS_SRC_IDL;
                          data_bus_src = `DATA_BUS_SRC_RMWL;
                       end
                       'b101: begin
                          `CONTROL_ROM_BUNDLE = `UOP_NOP;
                          alu_op = {3'b101, aaa[1:0]};
                          alu_op1_src = `ALU_OP1_SRC_RMWL;
                          rw_control = `RW_CONTROL_WRITE;
                          addr_bus_src = `ADDR_BUS_SRC_IDL;
                          data_bus_src = `DATA_BUS_SRC_ALU_OUT;
                          cyc_count_control = `CYC_COUNT_RESET;
                       end
                     endcase
                  end
                endcase // case ({aaa, bbb})
             end

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
                input             nreset,
                output reg [15:0] addr,
                inout [7:0]       data,
                output reg        rw,
                input             nnmi,
                input             nirq,
                output reg        naddr4016r,
                output reg        naddr4017r,
                output reg [2:0]  addr4016w);

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

   // Read-modify-write latch
   reg [7:0]  RMWL;

   // output data latch
   reg [7:0] ODL;
   assign data = (rw == `RW_WRITE) ? ODL : 8'hzz;
   reg [2:0] cyc_count;

   //////////////// control rom
   wire [1:0] rw_control;
   wire [3:0] pc_src;
   wire [2:0] instr_reg_src;
   wire [1:0] idl_low_src;
   wire [1:0] idl_hi_src;
   wire [1:0] rmwl_src;
   wire [1:0] accum_src;
   wire [1:0] sp_src;
   wire [1:0] x_src;
   wire [1:0] y_src;
   wire [1:0] flags_src;
   wire [2:0] addr_bus_src;
   wire [2:0] data_bus_src;
   wire [4:0] alu_op;
   wire [2:0] alu_op1_src;
   wire [2:0] alu_op2_src;
   wire [2:0] cyc_count_control;
   control_rom cr(.instr(instr),
                  .cyc_count(cyc_count),
                  .rw_control(rw_control),
                  .pc_src(pc_src),
                  .instr_reg_src(instr_reg_src),
                  .idl_low_src(idl_low_src),
                  .idl_hi_src(idl_hi_src),
                  .rmwl_src(rmwl_src),
                  .accum_src(accum_src),
                  .sp_src(sp_src),
                  .x_src(x_src),
                  .y_src(y_src),
                  .flags_src(flags_src),
                  .addr_bus_src(addr_bus_src),
                  .data_bus_src(data_bus_src),
                  .alu_op(alu_op),
                  .alu_op1_src(alu_op1_src),
                  .alu_op2_src(alu_op2_src),
                  .cyc_count_control(cyc_count_control));

   //////////////// ALU
   // TODO: carry logic
   // TODO: flags register
   // TODO: figure out difference between carry and overflow flags!
   // NV-BDIZC
   // TODO: pch_carry signals are doing double-duty for program counter and IDL. needs rename.
   reg       pch_carryw;    // wire
   reg       pch_carry;     // latch latched in always @ (posedge clk) block
   reg [7:0] alu_out;
   reg [7:0] alu_op1;
   reg [7:0] alu_op2;
   reg [7:0] alu_flags_out;
   reg [7:0] alu_flags_overwrite;
   wire [7:0] op2_neg = ~alu_op2;
   reg       c6;
   always @ *
     begin
        case(alu_op1_src)
          `ALU_OP1_SRC_A:     alu_op1 = A;
          `ALU_OP1_SRC_DATA:  alu_op1 = data;
          `ALU_OP1_SRC_X:     alu_op1 = X;
          `ALU_OP1_SRC_Y:     alu_op1 = Y;
          `ALU_OP1_SRC_SP:    alu_op1 = SP;
          `ALU_OP1_SRC_RMWL:  alu_op1 = RMWL;
        endcase

        case(alu_op2_src)
          `ALU_OP2_SRC_DATA_BUS: alu_op2 = data;
          `ALU_OP2_SRC_IDL_LOW:  alu_op2 = IDL[7:0];
          `ALU_OP2_SRC_X:        alu_op2 = X;
          `ALU_OP2_SRC_Y:        alu_op2 = Y;
          `ALU_OP2_SRC_1:        alu_op2 = 8'h01;
          `ALU_OP2_SRC_NEG1:     alu_op2 = 8'hff;
        endcase

        c6 = 'h0;
        alu_flags_overwrite = 'h0;
        alu_flags_out = 'h0;
        alu_flags_out[1] = (alu_out == 8'h00);
        alu_flags_out[7] = alu_out[7];

        case(alu_op)
          `ALU_OP_OR:  begin
             alu_out = alu_op1 | alu_op2;
             alu_flags_overwrite = 8'b1000_0010;
             alu_flags_out = {alu_out[7], 5'h0, (alu_out == 8'h00), 1'h0};
          end

          `ALU_OP_AND: begin
             alu_out = alu_op1 & alu_op2;
             alu_flags_overwrite = 8'b1000_0010;
             alu_flags_out = {alu_out[7], 5'h0, (alu_out == 8'h00), 1'h0};
          end

          `ALU_OP_EOR: begin
             alu_out = alu_op1 ^ alu_op2;
             alu_flags_overwrite = 8'b1000_0010;
             alu_flags_out = {alu_out[7], 5'h0, (alu_out == 8'h00), 1'h0};
          end

          `ALU_OP_ADC: begin
             {c6, alu_out[6:0]} = A[6:0] + alu_op2[6:0] + flags[0];
             {alu_flags_out[0], alu_out[7]} = A[7] + alu_op2[7] + c6;
             alu_flags_out[6] = c6 ^ alu_flags_out[0];
             alu_flags_overwrite = 8'b1100_0011;
          end

          `ALU_OP_STA: begin
             alu_out = 8'h0;
          end

          // LDA
          `ALU_OP_FWD_OP2: begin
             alu_out = alu_op2;
             alu_flags_out[7] = alu_out[7]; // n
             alu_flags_out[1] = (alu_out == 'h0);
             alu_flags_overwrite = 8'b1000_0010;
          end

          `ALU_OP_CMP: begin
             {alu_flags_out[0], alu_out} = alu_op1 + op2_neg + 8'h01;
             alu_flags_overwrite = 8'b1000_0011;
             alu_flags_out[7] = alu_out[7];
             alu_flags_out[1] = (alu_out == 'h0);
             alu_out = A;    // cheap trick to avoid adding extra cases to control rom
          end

          `ALU_OP_SBC: begin
             {c6, alu_out[6:0]} = A[6:0] + op2_neg[6:0] + flags[0];
             {alu_flags_out[0], alu_out[7]} = A[7] + op2_neg[7] + c6;
             alu_flags_out[6] = c6 ^ alu_flags_out[0];
             alu_flags_overwrite = 8'b1100_0011;
          end

          `ALU_OP_BIT: begin
             alu_out = 8'h00;
             //A AND M, M7 -> N, M6 -> V
             alu_flags_overwrite = 1100_0010;
             alu_flags_out[7] = alu_op2[7];
             alu_flags_out[6] = alu_op2[6];
             alu_flags_out[1] = ((alu_op1 & alu_op2) == 'h00);
          end

          `ALU_OP_NOP: begin
             alu_out = 8'h00;
             alu_flags_overwrite = 8'h00;
          end

          `ALU_OP_PCL: {pch_carryw, alu_out} = PC[7:0] + IDL[7:0];
          `ALU_OP_PCH: alu_out = PC[15:8] + (pch_carry + {8{IDL[7]}});
          `ALU_OP_IDLL_ADD: {pch_carryw, alu_out} = IDL[7:0] + alu_op2;

          `ALU_OP_CLC, `ALU_OP_SEC: begin
             alu_flags_out[0] = (alu_op == `ALU_OP_SEC) ? 1'b1 : 1'b0;
             alu_flags_overwrite = 8'b0000_0001;
          end

          `ALU_OP_CLV: begin
             alu_flags_out[6] = 1'b0;
             alu_flags_overwrite = 8'b0100_0000;
          end

          `ALU_OP_INC: begin
             alu_out = alu_op1 + alu_op2;
             alu_flags_out[7] = alu_out[7];
             alu_flags_out[1] = (alu_out == 8'h00);
             alu_flags_overwrite = 8'b1000_0010;
          end

          `ALU_OP_INC_NOFLAGS: begin
             alu_out = alu_op1 + alu_op2;
             alu_flags_overwrite = 8'b0000_0000;
          end

          `ALU_OP_ASL, `ALU_OP_ROL: begin
             if (alu_op == `ALU_OP_ASL) begin
                alu_out = {alu_op1[6:0], 1'b0};
             end else begin
                alu_out = {alu_op1[6:0], flags[0]};
             end
             alu_flags_overwrite = 8'b1000_0011;
             alu_flags_out[7] = alu_out[7];
             alu_flags_out[1] = (alu_out == 8'h00);
             alu_flags_out[0] = alu_op1[7];
          end

          `ALU_OP_LSR, `ALU_OP_ROR: begin
             if (alu_op == `ALU_OP_LSR) begin
                alu_out = {1'b0, alu_op1[6:0]};
                alu_flags_overwrite = 8'b0000_0011;
             end else begin
                alu_flags_overwrite = 8'b1000_0011;
                alu_out = {flags[0], alu_op1[6:0]};
             end
             alu_flags_out[7] = alu_out[7];
             alu_flags_out[1] = (alu_out == 8'h00);
             alu_flags_out[0] = alu_op1[7];
          end
          default: alu_out = 8'ha5;
        endcase
     end

   //////////////// mux for address bus
   always @ *
     begin
        case(addr_bus_src)
          `ADDR_BUS_SRC_PC: addr = PC;
          `ADDR_BUS_SRC_IDL_LOW: addr = {8'b0, IDL[7:0]};
          `ADDR_BUS_SRC_IDL: addr = IDL;
          `ADDR_BUS_SRC_SP: addr = {8'h01, SP};
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
          `DATA_BUS_SRC_FLAGS: ODL = flags;
          `DATA_BUS_SRC_ALU_OUT: ODL = alu_out;
          `DATA_BUS_SRC_RMWL: ODL = RMWL;
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

   //////////////// R/W signal
   always @ *
     begin
        case(rw_control)
          `RW_CONTROL_WRITE:      rw <= `RW_WRITE;
          `RW_CONTROL_READ:       rw <= `RW_READ;
          `RW_CONTROL_WRITE_WHEN_PAGE_READY: begin
             if (pch_carry) begin
                rw <= `RW_READ;
             end else begin
                rw <= `RW_WRITE;
             end
          end
        endcase
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
            `ACCUM_SRC_X:       A <= X;
            `ACCUM_SRC_Y:       A <= Y;
          endcase

          case(sp_src)
            `SP_SRC_SP:        SP <= SP;
            `SP_SRC_ALU_OUT:    SP <= alu_out;
            `SP_SRC_X:         SP <= X;
          endcase

          case(x_src)
            `X_SRC_X:        X <= X;
            `X_SRC_ACCUM:    X <= A;
            `X_SRC_ALU_OUT:  X <= alu_out;
            `X_SRC_SP:       X <= SP;
          endcase

          case(y_src)
            `Y_SRC_Y:     Y <= Y;
            `Y_SRC_ACCUM: Y <= A;
            `Y_SRC_ALU_OUT:  Y <= alu_out;
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
            `IDL_LOW_SRC_ALU_OUT:  IDL[7:0] <= alu_out;
          endcase
          case(idl_hi_src)
            `IDL_HI_SRC_IDL_HI:   IDL[15:8] <= IDL[15:8];
            `IDL_HI_SRC_DATA_BUS: IDL[15:8] <= data[7:0];
            `IDL_HI_SRC_IDL_HI_CARRY: IDL[15:8] <= IDL[15:8] + pch_carry;
          endcase

          // update read-modify-write latch
          case(rmwl_src)
            `RMWL_SRC_RMWL:     RMWL <= RMWL;
            `RMWL_SRC_DATA_BUS: RMWL <= data;
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
            `CYC_COUNT_RESET_IF_IDX_SAMEPAGE: cyc_count <= pch_carry ? cyc_count + 1 : 'b0;
            `CYC_COUNT_SET1_IF_PC_SAMEPAGE: cyc_count <= page_boundary_crossed ? cyc_count + 1 : 'b1;
          endcase

          pch_carry <= pch_carryw;

          // flags register
          case(flags_src)
            `FLAGS_SRC_NEXT: begin
               for (i = 0; i < 8; i = i + 1) begin
                  flags[i] <= alu_flags_overwrite[i] ? alu_flags_out[i] : flags[i];
               end
            end
            `FLAGS_SRC_DATA_BUS: flags <= data;
          endcase
       end
     else
       begin
          // reset all registers
          PC        <= 'b0;
          SP        <= 8'hff;
          A         <= 'b0;
          X         <= 'b0;
          Y         <= 'b0;

          pch_carry <= 'b0;
          instr     <= 'b0;
          flags     <= 'b0;
          IDL       <= 'b0;
          ODL       <= 'b0;
          cyc_count <= 'b0;
       end // else: !if(nreset)
     end // always @(posedge clock)
endmodule
