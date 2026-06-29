module ID_Stage (
    input clk,
    input rst,
    input [31:0] PC_in,
    input [31:0] Instruction_in,
    input [3:0] SR,
    input Hazard,
    input WB_WB_EN,
    input [3:0] WB_WB_Dest,
    input [31:0] WB_WB_Value,

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

    wire [3:0] cond;
    wire [1:0] mode;
    wire I;
    wire [3:0] opcode;
    wire S_bit;
    wire [3:0] Rn;
    wire [3:0] Rd;
    wire [3:0] Rm;

    wire [3:0] src2_selected;
    wire [31:0] reg_out_1;
    wire [31:0] reg_out_2;

    wire [3:0] uncond_EXE_CMD;
    wire uncond_MEM_R_EN;
    wire uncond_MEM_W_EN;
    wire uncond_WB_EN;
    wire uncond_imm;
    wire uncond_B;
    wire uncond_S;

    wire condition_passed;
    wire control_enable;
    wire is_branch;
    wire is_mov_like;

    assign cond = Instruction_in[31:28];
    assign mode = Instruction_in[27:26];
    assign I = Instruction_in[25];
    assign opcode = Instruction_in[24:21];
    assign S_bit = Instruction_in[20];
    assign Rn = Instruction_in[19:16];
    assign Rd = Instruction_in[15:12];
    assign Rm = Instruction_in[3:0];

    assign src2_selected = uncond_MEM_W_EN ? Rd : Rm;
    assign is_branch = (mode == 2'b10);
    assign is_mov_like = (mode == 2'b00) && ((opcode == 4'b1101) || (opcode == 4'b1111));

    ControlUnit CONTROL_UNIT (
        .mode(mode),
        .opcode(opcode),
        .S(S_bit),
        .I(I),
        .EXE_CMD(uncond_EXE_CMD),
        .MEM_R_EN(uncond_MEM_R_EN),
        .MEM_W_EN(uncond_MEM_W_EN),
        .WB_EN(uncond_WB_EN),
        .imm(uncond_imm),
        .B(uncond_B),
        .S_out(uncond_S)
    );

    ConditionCheck CONDITION_CHECK (
        .cond(cond),
        .SR(SR),
        .condition_passed(condition_passed)
    );

    RegisterFile REGISTER_FILE (
        .clk(clk),
        .rst(rst),
        .src_1(Rn),
        .src_2(src2_selected),
        .Dest_WB(WB_WB_Dest),
        .Result_WB(WB_WB_Value),
        .writeBackEN(WB_WB_EN),
        .reg_out_1(reg_out_1),
        .reg_out_2(reg_out_2)
    );

    assign control_enable = condition_passed & ~Hazard;

    always @(*) begin
        PC = PC_in;
        Instruction = Instruction_in;

        Val_Rn = (Rn == 4'd15) ? PC_in : reg_out_1;
        Val_Rm = (src2_selected == 4'd15) ? PC_in : reg_out_2;

        shift_operand = Instruction_in[11:0];
        signed_imm_24 = Instruction_in[23:0];
        Dest = Rd;
        src1 = (is_branch || is_mov_like) ? 4'd15 : Rn;
        src2 = src2_selected;

        Two_src = (~is_branch) && (((~uncond_imm) && (~is_mov_like)) || uncond_MEM_W_EN);

        EXE_CMD  = control_enable ? uncond_EXE_CMD  : 4'b0000;
        MEM_R_EN = control_enable ? uncond_MEM_R_EN : 1'b0;
        MEM_W_EN = control_enable ? uncond_MEM_W_EN : 1'b0;
        WB_EN    = control_enable ? uncond_WB_EN    : 1'b0;
        imm      = control_enable ? uncond_imm      : 1'b0;
        B        = control_enable ? uncond_B        : 1'b0;
        S        = control_enable ? uncond_S        : 1'b0;
    end

endmodule
