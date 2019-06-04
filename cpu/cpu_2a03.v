/**
 * This code copyright James Connolly and John Mamish, 2019
 *
 *
 */

`define DEFINED

`include "control_values.v"
`include "micro_ops.v"
`include "control_rom.v"

`timescale 1ns/100ps

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
 * @input  data_in  - System data bus from mem to cpu
 * @output data_out - System data bus from cpu to mem
 * @output rw       - direction of 6502's data bus (0=write;1=read)
 *
 */
module cpu_2a03(input clock,
                input             nreset,
                output reg [15:0] addr,
                input [7:0]       data_in,
                output reg [7:0]  data_out,
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
   wire [2:0] x_src;
   wire [2:0] y_src;
   wire [1:0] flags_src;
   wire [2:0] addr_bus_src;
   wire [3:0] data_bus_src;
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
          `ALU_OP1_SRC_DATA:  alu_op1 = data_in;
          `ALU_OP1_SRC_X:     alu_op1 = X;
          `ALU_OP1_SRC_Y:     alu_op1 = Y;
          `ALU_OP1_SRC_SP:    alu_op1 = SP;
          `ALU_OP1_SRC_RMWL:  alu_op1 = RMWL;
          `ALU_OP1_SRC_IDL_LOW: alu_op1 = IDL[7:0];
          default:            alu_op1 = 'h00;
        endcase

        case(alu_op2_src)
          `ALU_OP2_SRC_DATA_BUS: alu_op2 = data_in;
          `ALU_OP2_SRC_IDL_LOW:  alu_op2 = IDL[7:0];
          `ALU_OP2_SRC_X:        alu_op2 = X;
          `ALU_OP2_SRC_Y:        alu_op2 = Y;
          `ALU_OP2_SRC_1:        alu_op2 = 8'h01;
          `ALU_OP2_SRC_NEG1:     alu_op2 = 8'hff;
          default:               alu_op2 = 'h00;
        endcase

        c6 = 'h0;
        alu_out = 'h0;
        alu_flags_overwrite = 'h0;
        alu_flags_out = 'h0;
        pch_carryw = pch_carry;

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
             alu_flags_out[7] = alu_out[7];
             alu_flags_out[6] = c6 ^ alu_flags_out[0];
             alu_flags_out[1] = (alu_out == 8'h00);
             alu_flags_overwrite = 8'b1100_0011;
          end

          `ALU_OP_STA: begin
             alu_out = 8'h00;
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
          `ALU_OP_IDLH_ADD: {pch_carryw, alu_out} = IDL[15:8] + alu_op2;

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
          end // case: `ALU_OP_LSR, `ALU_OP_ROR

          default: begin
             alu_out = 8'h00;
          end
        endcase // case (alu_op)
     end

   //////////////// mux for address bus
   always @ *
     begin
        case(addr_bus_src)
          `ADDR_BUS_SRC_PC: addr = PC;
          `ADDR_BUS_SRC_IDL_LOW: addr = {8'b0, IDL[7:0]};
          `ADDR_BUS_SRC_IDL: addr = IDL;
          `ADDR_BUS_SRC_SP: addr = {8'h01, SP};
          default:          addr = 16'h0000;
        endcase
     end

   //////////////// mux for data bus
   always @ *
     begin
        data_out = 'h0;
        case(data_bus_src)
          `DATA_BUS_SRC_NONE: data_out = 8'h00;
          `DATA_BUS_SRC_ACCUM: data_out = A;
          `DATA_BUS_SRC_X: data_out = X;
          `DATA_BUS_SRC_Y: data_out = Y;
          `DATA_BUS_SRC_FLAGS: data_out = flags;
          `DATA_BUS_SRC_ALU_OUT: data_out = alu_out;
          `DATA_BUS_SRC_RMWL: data_out = RMWL;
          `DATA_BUS_SRC_PCH: data_out = PC[15:8];
          `DATA_BUS_SRC_PCL: data_out = PC[7:0];
          default data_out = 'h00;
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
           default: rw <= `RW_READ;
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
            `Y_SRC_Y:        Y <= Y;
            `Y_SRC_ACCUM:    Y <= A;
            `Y_SRC_ALU_OUT:  Y <= alu_out;
          endcase

          // instruction register
          case(instr_reg_src)
            `INSTR_REG_SRC_INSTR_REG: instr <= instr;
            `INSTR_REG_SRC_DATA_BUS:  instr <= data_in;
            `INSTR_REG_SRC_DATA_BUS_IF_NOBRANCH: instr <= (do_branch) ? instr : data_in;
            `INSTR_REG_SRC_DATA_BUS_IF_SAMEPAGE: instr <= (page_boundary_crossed) ? instr : data_in;
          endcase

          // update internal data latch
          case(idl_low_src)
            `IDL_LOW_SRC_IDL_LOW:  IDL[7:0] <= IDL[7:0];
            `IDL_LOW_SRC_DATA_BUS: IDL[7:0] <= data_in[7:0];
            `IDL_LOW_SRC_ALU_OUT:  IDL[7:0] <= alu_out;
            `IDL_LOW_SRC_IDL_HI:   IDL[7:0] <= IDL[15:8];
          endcase
          case(idl_hi_src)
            `IDL_HI_SRC_IDL_HI:   IDL[15:8] <= IDL[15:8];
            `IDL_HI_SRC_DATA_BUS: IDL[15:8] <= data_in[7:0];
            `IDL_HI_SRC_IDL_HI_CARRY: IDL[15:8] <= IDL[15:8] + pch_carry;
            `IDL_HI_SRC_ALU_OUT: IDL[15:8] <= alu_out;
          endcase

          // update read-modify-write latch
          case(rmwl_src)
            `RMWL_SRC_RMWL:     RMWL <= RMWL;
            `RMWL_SRC_DATA_BUS: RMWL <= data_in;
          endcase

          // update program counter
          casez(pc_src)
            `PC_SRC_PC:           PC <= PC;
            `PC_SRC_PC_PLUS1:     PC <= PC + 1;
            `PCH_SRC_DATABUS_PCL_SRC_IDLL:     PC <= {data_in, IDL[7:0]};

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
            `FLAGS_SRC_DATA_BUS: flags <= data_in;
            default: flags <= flags;
          endcase
       end
     else
       begin
          // reset all registers
          PC        <= 'h0600;
          SP        <= 8'hff;
          A         <= 'b0;
          X         <= 'b0;
          Y         <= 'b0;

          pch_carry <= 'b0;
          instr     <= 'b0;
          flags     <= 'b0;
          IDL       <= 'b0;
          cyc_count <= 'b0;
       end // else: !if(nreset)
     end // always @(posedge clock)
endmodule
