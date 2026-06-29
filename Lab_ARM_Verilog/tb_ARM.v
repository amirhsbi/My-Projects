`timescale 1ns/1ps

module tb_ARM;

    reg clk;
    reg rst;
    reg Forwarding_EN;

    wire [31:0] IF_PC;
    wire [31:0] IF_Instruction;
    wire [31:0] ID_Reg_PC;
    wire [31:0] ID_Reg_Instruction;
    wire [31:0] ID_Reg_Val_Rn;
    wire [31:0] ID_Reg_Val_Rm;
    wire [3:0] ID_Reg_Dest;
    wire [3:0] ID_Reg_EXE_CMD;
    wire ID_Reg_MEM_R_EN;
    wire ID_Reg_MEM_W_EN;
    wire ID_Reg_WB_EN;
    wire ID_Reg_imm;
    wire ID_Reg_B;
    wire ID_Reg_S;

    wire [31:0] EXE_ALU_res;
    wire [31:0] EXE_Branch_Address;
    wire [3:0] EXE_Dest;
    wire [3:0] EXE_SR;
    wire EXE_WB_EN;
    wire EXE_MEM_R_EN;
    wire EXE_MEM_W_EN;
    wire EXE_B;

    wire [31:0] MEM_ALU_res;
    wire [31:0] MEM_Data_Mem_out;
    wire [3:0] MEM_Dest;
    wire MEM_WB_EN;
    wire MEM_MEM_R_EN;
    wire MEM_MEM_W_EN;

    wire [31:0] WB_WB_Value;
    wire [3:0] WB_WB_Dest;
    wire WB_WB_EN;
    wire Detected_Hazard;
    wire [1:0] Forward_Sel_Src1;
    wire [1:0] Forward_Sel_Src2;

    ARM uut (
        .clk(clk),
        .rst(rst),
        .Forwarding_EN(Forwarding_EN),
        .IF_PC(IF_PC),
        .IF_Instruction(IF_Instruction),
        .ID_Reg_PC(ID_Reg_PC),
        .ID_Reg_Instruction(ID_Reg_Instruction),
        .ID_Reg_Val_Rn(ID_Reg_Val_Rn),
        .ID_Reg_Val_Rm(ID_Reg_Val_Rm),
        .ID_Reg_Dest(ID_Reg_Dest),
        .ID_Reg_EXE_CMD(ID_Reg_EXE_CMD),
        .ID_Reg_MEM_R_EN(ID_Reg_MEM_R_EN),
        .ID_Reg_MEM_W_EN(ID_Reg_MEM_W_EN),
        .ID_Reg_WB_EN(ID_Reg_WB_EN),
        .ID_Reg_imm(ID_Reg_imm),
        .ID_Reg_B(ID_Reg_B),
        .ID_Reg_S(ID_Reg_S),
        .EXE_ALU_res(EXE_ALU_res),
        .EXE_Branch_Address(EXE_Branch_Address),
        .EXE_Dest(EXE_Dest),
        .EXE_SR(EXE_SR),
        .EXE_WB_EN(EXE_WB_EN),
        .EXE_MEM_R_EN(EXE_MEM_R_EN),
        .EXE_MEM_W_EN(EXE_MEM_W_EN),
        .EXE_B(EXE_B),
        .MEM_ALU_res(MEM_ALU_res),
        .MEM_Data_Mem_out(MEM_Data_Mem_out),
        .MEM_Dest(MEM_Dest),
        .MEM_WB_EN(MEM_WB_EN),
        .MEM_MEM_R_EN(MEM_MEM_R_EN),
        .MEM_MEM_W_EN(MEM_MEM_W_EN),
        .WB_WB_Value(WB_WB_Value),
        .WB_WB_Dest(WB_WB_Dest),
        .WB_WB_EN(WB_WB_EN),
        .Detected_Hazard(Detected_Hazard),
        .Forward_Sel_Src1(Forward_Sel_Src1),
        .Forward_Sel_Src2(Forward_Sel_Src2)
    );

    initial begin
        clk = 1'b0;
        forever #5 clk = ~clk;
    end

    initial begin
        $dumpfile("arm_forwarding.vcd");
        $dumpvars(0, tb_ARM);

        Forwarding_EN = 1'b0;
        rst = 1'b1;
        #12;
        rst = 1'b0;
        #600;

        rst = 1'b1;
        #20;
        Forwarding_EN = 1'b1;
        rst = 1'b0;
        #600;

        $stop;
    end

    initial begin
        $monitor("t=%0t FWD=%b rst=%b PC=%0d IF=%h ID=%h H=%b SEL1=%b SEL2=%b EXE_DEST=%0d EXE_WB=%b EXE_MEM_R=%b MEM_ADDR=%0d MEM_R=%b MEM_W=%b MEM_DOUT=%0d WB_EN=%b WB_DEST=%0d WB_VAL=%0d R0=%0d R1=%0d R2=%0d R3=%0d R4=%0d R5=%0d R6=%0d",
            $time,
            Forwarding_EN,
            rst,
            IF_PC,
            IF_Instruction,
            ID_Reg_Instruction,
            Detected_Hazard,
            Forward_Sel_Src1,
            Forward_Sel_Src2,
            EXE_Dest,
            EXE_WB_EN,
            EXE_MEM_R_EN,
            MEM_ALU_res,
            MEM_MEM_R_EN,
            MEM_MEM_W_EN,
            MEM_Data_Mem_out,
            WB_WB_EN,
            WB_WB_Dest,
            WB_WB_Value,
            uut.ID_STAGE.REGISTER_FILE.registers[0],
            uut.ID_STAGE.REGISTER_FILE.registers[1],
            uut.ID_STAGE.REGISTER_FILE.registers[2],
            uut.ID_STAGE.REGISTER_FILE.registers[3],
            uut.ID_STAGE.REGISTER_FILE.registers[4],
            uut.ID_STAGE.REGISTER_FILE.registers[5],
            uut.ID_STAGE.REGISTER_FILE.registers[6]
        );
    end

endmodule
