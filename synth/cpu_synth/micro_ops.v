`ifndef MICRO_OPS_V
`define MICRO_OPS_V

`include "control_values.v"

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

`endif
