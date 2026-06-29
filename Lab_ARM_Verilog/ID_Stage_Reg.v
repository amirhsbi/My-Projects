module ID_Stage_Reg (
    input clk,
    input rst,
    input freeze,
    input flush,

    input [31:0] PC_in,
    input [31:0] Instruction_in,
    input [31:0] Val_Rn_in,
    input [31:0] Val_Rm_in,
    input [11:0] shift_operand_in,
    input [23:0] signed_imm_24_in,
    input [3:0] Dest_in,
    input [3:0] src1_in,
    input [3:0] src2_in,
    input Two_src_in,
    input [3:0] EXE_CMD_in,
    input MEM_R_EN_in,
    input MEM_W_EN_in,
    input WB_EN_in,
    input imm_in,
    input B_in,
    input S_in,

    output reg [31:0] PC,
    output reg [31:0] Instruction,
    output reg [31:0] Val_Rn,
    output reg [31:0] Val_Rm,
    output reg [11:0] shift_operand,
    output reg [23:0] signed_imm_24,
    output reg [3:0] Dest,
    output reg [3:0] src1,
    output reg [3:0] src2,
    output reg Two_src,
    output reg [3:0] EXE_CMD,
    output reg MEM_R_EN,
    output reg MEM_W_EN,
    output reg WB_EN,
    output reg imm,
    output reg B,
    output reg S
);

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            PC <= 32'b0;
            Instruction <= 32'b0;
            Val_Rn <= 32'b0;
            Val_Rm <= 32'b0;
            shift_operand <= 12'b0;
            signed_imm_24 <= 24'b0;
            Dest <= 4'b0;
            src1 <= 4'b0;
            src2 <= 4'b0;
            Two_src <= 1'b0;
            EXE_CMD <= 4'b0;
            MEM_R_EN <= 1'b0;
            MEM_W_EN <= 1'b0;
            WB_EN <= 1'b0;
            imm <= 1'b0;
            B <= 1'b0;
            S <= 1'b0;
        end
        else if (flush) begin
            PC <= 32'b0;
            Instruction <= 32'b0;
            Val_Rn <= 32'b0;
            Val_Rm <= 32'b0;
            shift_operand <= 12'b0;
            signed_imm_24 <= 24'b0;
            Dest <= 4'b0;
            src1 <= 4'b0;
            src2 <= 4'b0;
            Two_src <= 1'b0;
            EXE_CMD <= 4'b0;
            MEM_R_EN <= 1'b0;
            MEM_W_EN <= 1'b0;
            WB_EN <= 1'b0;
            imm <= 1'b0;
            B <= 1'b0;
            S <= 1'b0;
        end
        else if (!freeze) begin
            PC <= PC_in;
            Instruction <= Instruction_in;
            Val_Rn <= Val_Rn_in;
            Val_Rm <= Val_Rm_in;
            shift_operand <= shift_operand_in;
            signed_imm_24 <= signed_imm_24_in;
            Dest <= Dest_in;
            src1 <= src1_in;
            src2 <= src2_in;
            Two_src <= Two_src_in;
            EXE_CMD <= EXE_CMD_in;
            MEM_R_EN <= MEM_R_EN_in;
            MEM_W_EN <= MEM_W_EN_in;
            WB_EN <= WB_EN_in;
            imm <= imm_in;
            B <= B_in;
            S <= S_in;
        end
    end

endmodule
