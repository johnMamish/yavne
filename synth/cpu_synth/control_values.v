`ifndef CONTROL_VALUES_V
`define CONTROL_VALUES_V

`timescale 1ns/100ps

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
// add op1 and op2 without carry and without modifying flags for SP.
`define ALU_OP_INC_NOFLAGS 5'hf

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

`endif
