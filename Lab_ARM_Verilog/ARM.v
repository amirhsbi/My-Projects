module ARM (
    input clk,
    input rst,
    input Forwarding_EN,

    output [31:0] IF_PC,
    output [31:0] IF_Instruction,

    output [31:0] ID_PC,
    output [31:0] ID_Instruction,
    output [31:0] ID_Val_Rn,
    output [31:0] ID_Val_Rm,
    output [11:0] ID_shift_operand,
    output [23:0] ID_signed_imm_24,
    output [3:0] ID_Dest,
    output [3:0] ID_src1,
    output [3:0] ID_src2,
    output ID_Two_src,
    output [3:0] ID_EXE_CMD,
    output ID_MEM_R_EN,
    output ID_MEM_W_EN,
    output ID_WB_EN,
    output ID_imm,
    output ID_B,
    output ID_S,

    output [31:0] ID_Reg_PC,
    output [31:0] ID_Reg_Instruction,
    output [31:0] ID_Reg_Val_Rn,
    output [31:0] ID_Reg_Val_Rm,
    output [11:0] ID_Reg_shift_operand,
    output [23:0] ID_Reg_signed_imm_24,
    output [3:0] ID_Reg_Dest,
    output [3:0] ID_Reg_src1,
    output [3:0] ID_Reg_src2,
    output ID_Reg_Two_src,
    output [3:0] ID_Reg_EXE_CMD,
    output ID_Reg_MEM_R_EN,
    output ID_Reg_MEM_W_EN,
    output ID_Reg_WB_EN,
    output ID_Reg_imm,
    output ID_Reg_B,
    output ID_Reg_S,

    output [31:0] EXE_PC,
    output [31:0] EXE_Instruction,
    output [31:0] EXE_ALU_res,
    output [31:0] EXE_Val_Rm,
    output [31:0] EXE_Branch_Address,
    output [3:0] EXE_Dest,
    output [3:0] EXE_SR,
    output EXE_WB_EN,
    output EXE_MEM_R_EN,
    output EXE_MEM_W_EN,
    output EXE_B,

    output [31:0] EXE_Reg_PC,
    output [31:0] EXE_Reg_Instruction,
    output [31:0] EXE_Reg_ALU_res,
    output [31:0] EXE_Reg_Val_Rm,
    output [31:0] EXE_Reg_Branch_Address,
    output [3:0] EXE_Reg_Dest,
    output [3:0] EXE_Reg_SR,
    output EXE_Reg_WB_EN,
    output EXE_Reg_MEM_R_EN,
    output EXE_Reg_MEM_W_EN,
    output EXE_Reg_B,

    output [31:0] MEM_PC,
    output [31:0] MEM_Instruction,
    output [31:0] MEM_ALU_res,
    output [31:0] MEM_Val_Rm,
    output [31:0] MEM_Data_Mem_out,
    output [3:0] MEM_Dest,
    output MEM_WB_EN,
    output MEM_MEM_R_EN,
    output MEM_MEM_W_EN,

    output [31:0] MEM_Reg_PC,
    output [31:0] MEM_Reg_Instruction,
    output [31:0] MEM_Reg_ALU_res,
    output [31:0] MEM_Reg_Data_Mem_out,
    output [3:0] MEM_Reg_Dest,
    output MEM_Reg_WB_EN,
    output MEM_Reg_MEM_R_EN,

    output [31:0] WB_PC,
    output [31:0] WB_Instruction,
    output [31:0] WB_Value,
    output [3:0] WB_Dest,
    output WB_EN,

    output [31:0] WB_Reg_PC,
    output [31:0] WB_Reg_Instruction,
    output [31:0] WB_WB_Value,
    output [3:0] WB_WB_Dest,
    output WB_WB_EN,

    output Detected_Hazard,
    output [1:0] Forward_Sel_Src1,
    output [1:0] Forward_Sel_Src2
);

    wire freeze_pc_if;
    wire flush_if_id;
    wire flush_id_ex;

    assign freeze_pc_if = Detected_Hazard;
    assign flush_if_id = EXE_B;
    assign flush_id_ex = EXE_B;

    wire [31:0] IF_Reg_PC;
    wire [31:0] IF_Reg_Instruction;

    HazardDetectionUnit HAZARD_DETECTION_UNIT (
        .Forwarding_EN(Forwarding_EN),
        .src1(ID_src1),
        .src2(ID_src2),
        .Two_src(ID_Two_src),
        .EXE_Dest(EXE_Dest),
        .MEM_Dest(EXE_Reg_Dest),
        .EXE_WB_EN(EXE_WB_EN),
        .MEM_WB_EN(EXE_Reg_WB_EN),
        .EXE_MEM_R_EN(EXE_MEM_R_EN),
        .Detected_Hazard(Detected_Hazard)
    );

    IF_Stage IF_STAGE (
        .clk(clk),
        .rst(rst),
        .freeze(freeze_pc_if),
        .Branch_taken(EXE_B),
        .BranchAddr(EXE_Branch_Address),
        .PC(IF_PC),
        .Instruction(IF_Instruction)
    );

    IF_Stage_Reg IF_STAGE_REG (
        .clk(clk),
        .rst(rst),
        .freeze(freeze_pc_if),
        .flush(flush_if_id),
        .PC_in(IF_PC),
        .Instruction_in(IF_Instruction),
        .PC(IF_Reg_PC),
        .Instruction(IF_Reg_Instruction)
    );

    ID_Stage ID_STAGE (
        .clk(clk),
        .rst(rst),
        .PC_in(IF_Reg_PC),
        .Instruction_in(IF_Reg_Instruction),
        .SR(EXE_SR),
        .Hazard(Detected_Hazard),
        .WB_WB_EN(WB_WB_EN),
        .WB_WB_Dest(WB_WB_Dest),
        .WB_WB_Value(WB_WB_Value),
        .PC(ID_PC),
        .Instruction(ID_Instruction),
        .Val_Rn(ID_Val_Rn),
        .Val_Rm(ID_Val_Rm),
        .shift_operand(ID_shift_operand),
        .signed_imm_24(ID_signed_imm_24),
        .Dest(ID_Dest),
        .src1(ID_src1),
        .src2(ID_src2),
        .Two_src(ID_Two_src),
        .EXE_CMD(ID_EXE_CMD),
        .MEM_R_EN(ID_MEM_R_EN),
        .MEM_W_EN(ID_MEM_W_EN),
        .WB_EN(ID_WB_EN),
        .imm(ID_imm),
        .B(ID_B),
        .S(ID_S)
    );

    ID_Stage_Reg ID_STAGE_REG (
        .clk(clk),
        .rst(rst),
        .freeze(1'b0),
        .flush(flush_id_ex),
        .PC_in(ID_PC),
        .Instruction_in(ID_Instruction),
        .Val_Rn_in(ID_Val_Rn),
        .Val_Rm_in(ID_Val_Rm),
        .shift_operand_in(ID_shift_operand),
        .signed_imm_24_in(ID_signed_imm_24),
        .Dest_in(ID_Dest),
        .src1_in(ID_src1),
        .src2_in(ID_src2),
        .Two_src_in(ID_Two_src),
        .EXE_CMD_in(ID_EXE_CMD),
        .MEM_R_EN_in(ID_MEM_R_EN),
        .MEM_W_EN_in(ID_MEM_W_EN),
        .WB_EN_in(ID_WB_EN),
        .imm_in(ID_imm),
        .B_in(ID_B),
        .S_in(ID_S),
        .PC(ID_Reg_PC),
        .Instruction(ID_Reg_Instruction),
        .Val_Rn(ID_Reg_Val_Rn),
        .Val_Rm(ID_Reg_Val_Rm),
        .shift_operand(ID_Reg_shift_operand),
        .signed_imm_24(ID_Reg_signed_imm_24),
        .Dest(ID_Reg_Dest),
        .src1(ID_Reg_src1),
        .src2(ID_Reg_src2),
        .Two_src(ID_Reg_Two_src),
        .EXE_CMD(ID_Reg_EXE_CMD),
        .MEM_R_EN(ID_Reg_MEM_R_EN),
        .MEM_W_EN(ID_Reg_MEM_W_EN),
        .WB_EN(ID_Reg_WB_EN),
        .imm(ID_Reg_imm),
        .B(ID_Reg_B),
        .S(ID_Reg_S)
    );

    Forwarding_Unit FORWARDING_UNIT (
        .Forwarding_EN(Forwarding_EN),
        .src1(ID_Reg_src1),
        .src2(ID_Reg_src2),
        .Two_src(ID_Reg_Two_src),
        .MEM_Dest(EXE_Reg_Dest),
        .MEM_WB_EN(EXE_Reg_WB_EN),
        .WB_Dest(WB_Dest),
        .WB_WB_EN(WB_EN),
        .Sel_Src1(Forward_Sel_Src1),
        .Sel_Src2(Forward_Sel_Src2)
    );

    EXE_Stage EXE_STAGE (
        .clk(clk),
        .rst(rst),
        .PC_in(ID_Reg_PC),
        .Instruction_in(ID_Reg_Instruction),
        .Val_Rn_in(ID_Reg_Val_Rn),
        .Val_Rm_in(ID_Reg_Val_Rm),
        .MEM_Forward_Value(EXE_Reg_ALU_res),
        .WB_Forward_Value(WB_Value),
        .Sel_Src1(Forward_Sel_Src1),
        .Sel_Src2(Forward_Sel_Src2),
        .shift_operand_in(ID_Reg_shift_operand),
        .signed_imm_24_in(ID_Reg_signed_imm_24),
        .Dest_in(ID_Reg_Dest),
        .EXE_CMD_in(ID_Reg_EXE_CMD),
        .MEM_R_EN_in(ID_Reg_MEM_R_EN),
        .MEM_W_EN_in(ID_Reg_MEM_W_EN),
        .WB_EN_in(ID_Reg_WB_EN),
        .imm_in(ID_Reg_imm),
        .B_in(ID_Reg_B),
        .S_in(ID_Reg_S),
        .PC(EXE_PC),
        .Instruction(EXE_Instruction),
        .ALU_res(EXE_ALU_res),
        .Val_Rm(EXE_Val_Rm),
        .Branch_Address(EXE_Branch_Address),
        .Dest(EXE_Dest),
        .SR(EXE_SR),
        .WB_EN(EXE_WB_EN),
        .MEM_R_EN(EXE_MEM_R_EN),
        .MEM_W_EN(EXE_MEM_W_EN),
        .B(EXE_B)
    );

    EXE_Stage_Reg EXE_STAGE_REG (
        .clk(clk),
        .rst(rst),
        .freeze(1'b0),
        .flush(1'b0),
        .PC_in(EXE_PC),
        .Instruction_in(EXE_Instruction),
        .ALU_res_in(EXE_ALU_res),
        .Val_Rm_in(EXE_Val_Rm),
        .Branch_Address_in(EXE_Branch_Address),
        .Dest_in(EXE_Dest),
        .SR_in(EXE_SR),
        .WB_EN_in(EXE_WB_EN),
        .MEM_R_EN_in(EXE_MEM_R_EN),
        .MEM_W_EN_in(EXE_MEM_W_EN),
        .B_in(EXE_B),
        .PC(EXE_Reg_PC),
        .Instruction(EXE_Reg_Instruction),
        .ALU_res(EXE_Reg_ALU_res),
        .Val_Rm(EXE_Reg_Val_Rm),
        .Branch_Address(EXE_Reg_Branch_Address),
        .Dest(EXE_Reg_Dest),
        .SR(EXE_Reg_SR),
        .WB_EN(EXE_Reg_WB_EN),
        .MEM_R_EN(EXE_Reg_MEM_R_EN),
        .MEM_W_EN(EXE_Reg_MEM_W_EN),
        .B(EXE_Reg_B)
    );

    MEM_Stage MEM_STAGE (
        .clk(clk),
        .PC_in(EXE_Reg_PC),
        .Instruction_in(EXE_Reg_Instruction),
        .ALU_res_in(EXE_Reg_ALU_res),
        .Val_Rm_in(EXE_Reg_Val_Rm),
        .Dest_in(EXE_Reg_Dest),
        .WB_EN_in(EXE_Reg_WB_EN),
        .MEM_R_EN_in(EXE_Reg_MEM_R_EN),
        .MEM_W_EN_in(EXE_Reg_MEM_W_EN),
        .PC(MEM_PC),
        .Instruction(MEM_Instruction),
        .ALU_res(MEM_ALU_res),
        .Val_Rm(MEM_Val_Rm),
        .Data_Mem_out(MEM_Data_Mem_out),
        .Dest(MEM_Dest),
        .WB_EN(MEM_WB_EN),
        .MEM_R_EN(MEM_MEM_R_EN),
        .MEM_W_EN(MEM_MEM_W_EN)
    );

    MEM_Stage_Reg MEM_STAGE_REG (
        .clk(clk),
        .rst(rst),
        .freeze(1'b0),
        .flush(1'b0),
        .PC_in(MEM_PC),
        .Instruction_in(MEM_Instruction),
        .ALU_res_in(MEM_ALU_res),
        .Data_Mem_out_in(MEM_Data_Mem_out),
        .Dest_in(MEM_Dest),
        .WB_EN_in(MEM_WB_EN),
        .MEM_R_EN_in(MEM_MEM_R_EN),
        .PC(MEM_Reg_PC),
        .Instruction(MEM_Reg_Instruction),
        .ALU_res(MEM_Reg_ALU_res),
        .Data_Mem_out(MEM_Reg_Data_Mem_out),
        .Dest(MEM_Reg_Dest),
        .WB_EN(MEM_Reg_WB_EN),
        .MEM_R_EN(MEM_Reg_MEM_R_EN)
    );

    WB_Stage WB_STAGE (
        .PC_in(MEM_Reg_PC),
        .Instruction_in(MEM_Reg_Instruction),
        .ALU_res_in(MEM_Reg_ALU_res),
        .Data_Mem_out_in(MEM_Reg_Data_Mem_out),
        .Dest_in(MEM_Reg_Dest),
        .WB_EN_in(MEM_Reg_WB_EN),
        .MEM_R_EN_in(MEM_Reg_MEM_R_EN),
        .PC(WB_PC),
        .Instruction(WB_Instruction),
        .WB_Value(WB_Value),
        .WB_Dest(WB_Dest),
        .WB_EN(WB_EN)
    );

    WB_Stage_Reg WB_STAGE_REG (
        .clk(clk),
        .rst(rst),
        .freeze(1'b0),
        .flush(1'b0),
        .PC_in(WB_PC),
        .Instruction_in(WB_Instruction),
        .WB_Value_in(WB_Value),
        .WB_Dest_in(WB_Dest),
        .WB_EN_in(WB_EN),
        .PC(WB_Reg_PC),
        .Instruction(WB_Reg_Instruction),
        .WB_Value(WB_WB_Value),
        .WB_Dest(WB_WB_Dest),
        .WB_EN(WB_WB_EN)
    );

endmodule
