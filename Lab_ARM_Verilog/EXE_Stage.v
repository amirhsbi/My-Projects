module EXE_Stage (
    input clk,
    input rst,
    input [31:0] PC_in,
    input [31:0] Instruction_in,
    input [31:0] Val_Rn_in,
    input [31:0] Val_Rm_in,
    input [31:0] MEM_Forward_Value,
    input [31:0] WB_Forward_Value,
    input [1:0] Sel_Src1,
    input [1:0] Sel_Src2,
    input [11:0] shift_operand_in,
    input [23:0] signed_imm_24_in,
    input [3:0] Dest_in,
    input [3:0] EXE_CMD_in,
    input MEM_R_EN_in,
    input MEM_W_EN_in,
    input WB_EN_in,
    input imm_in,
    input B_in,
    input S_in,
    output reg [31:0] PC,
    output reg [31:0] Instruction,
    output [31:0] ALU_res,
    output [31:0] Val_Rm,
    output [31:0] Branch_Address,
    output [3:0] Dest,
    output [3:0] SR,
    output WB_EN,
    output MEM_R_EN,
    output MEM_W_EN,
    output B
);

    wire [31:0] Val1_selected;
    wire [31:0] Val_Rm_selected;
    wire [31:0] Val2;
    wire [3:0] alu_status;

    Mux3to1 #(.WIDTH(32)) SRC1_FORWARD_MUX (
        .in0(Val_Rn_in),
        .in1(MEM_Forward_Value),
        .in2(WB_Forward_Value),
        .sel(Sel_Src1),
        .out(Val1_selected)
    );

    Mux3to1 #(.WIDTH(32)) SRC2_FORWARD_MUX (
        .in0(Val_Rm_in),
        .in1(MEM_Forward_Value),
        .in2(WB_Forward_Value),
        .sel(Sel_Src2),
        .out(Val_Rm_selected)
    );

    Val2Generator VAL2_GENERATOR (
        .Val_Rm(Val_Rm_selected),
        .shift_operand(shift_operand_in),
        .imm(imm_in),
        .MEM_R_EN(MEM_R_EN_in),
        .MEM_W_EN(MEM_W_EN_in),
        .Val2(Val2)
    );

    ALU ALU_UNIT (
        .in1(Val1_selected),
        .in2(Val2),
        .EXE_CMD(EXE_CMD_in),
        .C_in(SR[1]),
        .result(ALU_res),
        .status(alu_status)
    );

    StatusRegister STATUS_REGISTER (
        .clk(clk),
        .rst(rst),
        .S(S_in),
        .status_in(alu_status),
        .SR(SR)
    );

    assign Branch_Address = PC_in + {{8{signed_imm_24_in[23]}}, signed_imm_24_in};
    assign Val_Rm = Val_Rm_selected;
    assign Dest = Dest_in;
    assign WB_EN = WB_EN_in;
    assign MEM_R_EN = MEM_R_EN_in;
    assign MEM_W_EN = MEM_W_EN_in;
    assign B = B_in;

    always @(*) begin
        PC = PC_in;
        Instruction = Instruction_in;
    end

endmodule
