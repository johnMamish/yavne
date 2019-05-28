`ifndef CONTROL_ROM_V
`define CONTROL_ROM_V

`include "control_values.v"
`include "micro_ops.v"

`timescale 1ns/100ps

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
                   output reg [2:0] x_src,
                   output reg [2:0] y_src,
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
        `CONTROL_ROM_BUNDLE = `UOP_NOP;

        // the first part of the instruction is always instruction fetch
        if (cyc_count == 'b0) begin
           `CONTROL_ROM_BUNDLE = `UOP_IFETCH;
           rw_control = `RW_CONTROL_READ;
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

                  // {CPX, CPY} zpg
                  {3'b11?, 3'h1}: begin
                     case(cyc_count)
                       'b001: `CONTROL_ROM_BUNDLE = `UOP_LOAD_IDL_LOW_FROM_PCPTR;
                       'b010: begin
                          `CONTROL_ROM_BUNDLE = `UOP_NOP;
                          addr_bus_src = `ADDR_BUS_SRC_IDL_LOW;
                          alu_op = `ALU_OP_CMP;
                          alu_op1_src = (aaa[0] == 1'b0) ? `ALU_OP1_SRC_Y : `ALU_OP1_SRC_X;
                          alu_op2_src = `ALU_OP2_SRC_DATA_BUS;
                          cyc_count_control = `CYC_COUNT_RESET;
                       end
                     endcase
                  end

                  // {CPX, CPY} abs
                  {3'b11?, 3'h3}: begin
                     case(cyc_count)
                       'b001: `CONTROL_ROM_BUNDLE = `UOP_LOAD_IDL_LOW_FROM_PCPTR;
                       'b010: `CONTROL_ROM_BUNDLE = `UOP_LOAD_IDL_HI_FROM_PCPTR;
                       'b011: begin
                          `CONTROL_ROM_BUNDLE = `UOP_NOP;
                          addr_bus_src = `ADDR_BUS_SRC_IDL;
                          alu_op = `ALU_OP_CMP;
                          alu_op1_src = (aaa[0] == 1'b0) ? `ALU_OP1_SRC_Y : `ALU_OP1_SRC_X;
                          alu_op2_src = `ALU_OP2_SRC_DATA_BUS;
                          cyc_count_control = `CYC_COUNT_RESET;
                       end
                     endcase
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
                       'b001: `CONTROL_ROM_BUNDLE = `UOP_LOAD_IDL_LOW_FROM_PCPTR;
                       'b010: begin
                          `CONTROL_ROM_BUNDLE = `UOP_ALUOP_ADD_IDL;
                          alu_op2_src = `ALU_OP2_SRC_X;
                       end
                       'b011: begin
                          `CONTROL_ROM_BUNDLE = `UOP_NOP;
                          idl_hi_src = `IDL_HI_SRC_DATA_BUS;
                          addr_bus_src = `ADDR_BUS_SRC_IDL_LOW;
                          idl_low_src = `IDL_LOW_SRC_ALU_OUT;
                          alu_op = `ALU_OP_INC_NOFLAGS;
                          alu_op1_src = `ALU_OP1_SRC_IDL_LOW;
                          alu_op2_src = `ALU_OP2_SRC_1;
                       end
                       'b100: begin
                          `CONTROL_ROM_BUNDLE = `UOP_NOP;
                          addr_bus_src = `ADDR_BUS_SRC_IDL_LOW;
                          idl_hi_src = `IDL_HI_SRC_DATA_BUS;
                          idl_low_src = `IDL_LOW_SRC_IDL_HI;
                       end
                       'b101: begin
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
                     case(cyc_count)
                       'b001: `CONTROL_ROM_BUNDLE = `UOP_LOAD_IDL_LOW_FROM_PCPTR;

                       // temporarily load low byte of ptr into idlh, increment idll
                       'b010: begin
                          `CONTROL_ROM_BUNDLE = `UOP_NOP;
                          addr_bus_src = `ADDR_BUS_SRC_IDL_LOW;
                          idl_hi_src = `IDL_HI_SRC_DATA_BUS;
                          idl_low_src = `IDL_LOW_SRC_ALU_OUT;
                          alu_op = `ALU_OP_INC_NOFLAGS;
                          alu_op1_src = `ALU_OP1_SRC_IDL_LOW;
                          alu_op2_src = `ALU_OP2_SRC_1;
                       end

                       // idll <= idlh + y; idlh <= data bus
                       'b011: begin
                          `CONTROL_ROM_BUNDLE = `UOP_NOP;
                          addr_bus_src = `ADDR_BUS_SRC_IDL_LOW;
                          idl_hi_src = `IDL_HI_SRC_DATA_BUS;
                          idl_low_src = `IDL_LOW_SRC_ALU_OUT;
                          alu_op = `ALU_OP_IDLH_ADD;
                          alu_op2_src = `ALU_OP2_SRC_Y;
                       end

                       'b100: begin
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
                       end // case: 'b100

                       'b101: begin
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
                     endcase
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

                  // LDX abs, Y
                  {3'h5, 3'h7}: begin
                     case(cyc_count)
                       'b001: `CONTROL_ROM_BUNDLE = `UOP_LOAD_IDL_LOW_FROM_PCPTR;

                       // IDLL <= X,Y + IDLL; IDLH <= *PC
                       'b010: begin
                          `CONTROL_ROM_BUNDLE = `UOP_LOAD_IDL_HI_FROM_PCPTR;
                          idl_low_src = `IDL_LOW_SRC_ALU_OUT;
                          alu_op      = `ALU_OP_IDLL_ADD;
                          alu_op2_src = `ALU_OP2_SRC_Y;
                       end

                       'b011: begin
                          `CONTROL_ROM_BUNDLE = `UOP_NOP;
                          addr_bus_src = `ADDR_BUS_SRC_IDL;
                          idl_hi_src = `IDL_HI_SRC_IDL_HI_CARRY;
                          cyc_count_control = `CYC_COUNT_RESET_IF_IDX_SAMEPAGE;
                          alu_op      = `ALU_OP_FWD_OP2;
                          x_src = `X_SRC_ALU_OUT;
                       end

                       'b100: begin
                          `CONTROL_ROM_BUNDLE = `UOP_NOP;
                          addr_bus_src = `ADDR_BUS_SRC_IDL;
                          cyc_count_control = `CYC_COUNT_RESET;
                          alu_op      = `ALU_OP_FWD_OP2;
                          x_src = `X_SRC_ALU_OUT;
                       end
                     endcase
                  end

                  {3'b10?, 3'b110}: begin
                     `CONTROL_ROM_BUNDLE = `UOP_NOP;
                     cyc_count_control = `CYC_COUNT_RESET;
                     if (aaa[0] == 1'b0) begin
                        sp_src = `SP_SRC_X;
                     end else begin
                        x_src = `X_SRC_SP;
                     end
                  end

                  //////////////// rotate zpg, {inc,dec} zpg
                  {3'b0??, 3'b001}, {3'b11?, 3'b001}: begin
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
                          alu_op1_src = `ALU_OP1_SRC_RMWL;
                          rw_control = `RW_CONTROL_WRITE;
                          addr_bus_src = `ADDR_BUS_SRC_IDL_LOW;
                          data_bus_src = `DATA_BUS_SRC_ALU_OUT;
                          cyc_count_control = `CYC_COUNT_RESET;
                          if (aaa[2] == 1'b0) begin
                             alu_op = {3'b101, aaa[1:0]};
                          end else begin
                             alu_op2_src = (aaa[0] == 1'b0) ? `ALU_OP2_SRC_NEG1 : `ALU_OP2_SRC_1;
                             alu_op = `ALU_OP_INC;
                          end
                       end
                     endcase
                  end // case: {3'b0??, 3'b001}

                  //////////////// rotate A
                  {3'b0??, 3'b010}: begin
                     `CONTROL_ROM_BUNDLE = `UOP_NOP;
                     accum_src = `ACCUM_SRC_ALU;
                     alu_op1_src = `ALU_OP1_SRC_A;
                     alu_op = {3'b101, aaa[1:0]};
                     cyc_count_control = `CYC_COUNT_RESET;
                  end

                  //////////////// rotate abs, {inc,dec} abs
                  {3'b0??, 3'b011}, {3'b11?, 3'b011}: begin
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
                          alu_op1_src = `ALU_OP1_SRC_RMWL;
                          rw_control = `RW_CONTROL_WRITE;
                          addr_bus_src = `ADDR_BUS_SRC_IDL;
                          data_bus_src = `DATA_BUS_SRC_ALU_OUT;
                          cyc_count_control = `CYC_COUNT_RESET;
                          if (aaa[2] == 1'b0) begin
                             alu_op = {3'b101, aaa[1:0]};
                          end else begin
                             alu_op2_src = (aaa[0] == 1'b0) ? `ALU_OP2_SRC_NEG1 : `ALU_OP2_SRC_1;
                             alu_op = `ALU_OP_INC;
                          end
                       end
                     endcase
                  end // case: {3'b0??, 3'b011}

                  //////////////// rotate zpg, X
                  {3'b0??, 3'b101}, {3'b11?, 3'b101}: begin
                     case(cyc_count)
                       'b001: `CONTROL_ROM_BUNDLE = `UOP_LOAD_IDL_LOW_FROM_PCPTR;
                       // IDL_low <= X + IDL_low
                       'b010: begin
                          `CONTROL_ROM_BUNDLE = `UOP_ALUOP_ADD_IDL;
                          alu_op2_src = `ALU_OP2_SRC_X;
                       end
                       'b011: begin
                          `CONTROL_ROM_BUNDLE = `UOP_LOAD_RMWL;
                          addr_bus_src = `ADDR_BUS_SRC_IDL_LOW;
                       end
                       'b100: begin
                          // this cycle is basically a nop
                          `CONTROL_ROM_BUNDLE = `UOP_NOP;
                          rw_control = `RW_CONTROL_WRITE;
                          addr_bus_src = `ADDR_BUS_SRC_IDL_LOW;
                          data_bus_src = `DATA_BUS_SRC_RMWL;
                       end
                       'b101: begin
                          `CONTROL_ROM_BUNDLE = `UOP_NOP;
                          alu_op1_src = `ALU_OP1_SRC_RMWL;
                          rw_control = `RW_CONTROL_WRITE;
                          addr_bus_src = `ADDR_BUS_SRC_IDL_LOW;
                          data_bus_src = `DATA_BUS_SRC_ALU_OUT;
                          cyc_count_control = `CYC_COUNT_RESET;
                          if (aaa[2] == 1'b0) begin
                             alu_op = {3'b101, aaa[1:0]};
                          end else begin
                             alu_op2_src = (aaa[0] == 1'b0) ? `ALU_OP2_SRC_NEG1 : `ALU_OP2_SRC_1;
                             alu_op = `ALU_OP_INC;
                          end
                       end
                     endcase
                  end // case: {3'b0??, 3'b011}

                  //////////////// rotate abs, X
                  {3'b0??, 3'b111}, {3'b11?, 3'b111}: begin
                     case(cyc_count)
                       'b001: `CONTROL_ROM_BUNDLE = `UOP_LOAD_IDL_LOW_FROM_PCPTR;

                       'b010: begin
                          `CONTROL_ROM_BUNDLE = `UOP_LOAD_IDL_HI_FROM_PCPTR;
                          idl_low_src = `IDL_LOW_SRC_ALU_OUT;
                          alu_op      = `ALU_OP_IDLL_ADD;
                          alu_op2_src = `ALU_OP2_SRC_X;
                       end

                       'b011: begin
                          // this cycle is basically a nop; bit it also corrects IDLH
                          `CONTROL_ROM_BUNDLE = `UOP_LOAD_RMWL;
                          idl_hi_src = `IDL_HI_SRC_IDL_HI_CARRY;
                       end

                       'b100: begin
                          // this cycle is basically a nop
                          `CONTROL_ROM_BUNDLE = `UOP_LOAD_RMWL;
                       end

                       'b101: begin
                          // this cycle is also basically a nop
                          `CONTROL_ROM_BUNDLE = `UOP_NOP;
                          rw_control = `RW_CONTROL_WRITE;
                          addr_bus_src = `ADDR_BUS_SRC_IDL;
                          data_bus_src = `DATA_BUS_SRC_RMWL;
                       end

                       'b110: begin
                          `CONTROL_ROM_BUNDLE = `UOP_NOP;
                          alu_op1_src = `ALU_OP1_SRC_RMWL;
                          rw_control = `RW_CONTROL_WRITE;
                          addr_bus_src = `ADDR_BUS_SRC_IDL;
                          data_bus_src = `DATA_BUS_SRC_ALU_OUT;
                          cyc_count_control = `CYC_COUNT_RESET;
                          if (aaa[2] == 1'b0) begin
                             alu_op = {3'b101, aaa[1:0]};
                          end else begin
                             alu_op2_src = (aaa[0] == 1'b0) ? `ALU_OP2_SRC_NEG1 : `ALU_OP2_SRC_1;
                             alu_op = `ALU_OP_INC;
                          end
                       end
                     endcase // case (cyc_count)
                  end

                  default: begin
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

`endif
