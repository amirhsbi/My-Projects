module EXE_Stage_Reg (
    input clk,
    input rst,
    input freeze,
    input flush,
    input [31:0] PC_in,
    input [31:0] Instruction_in,
    input [31:0] ALU_res_in,
    input [31:0] Val_Rm_in,
    input [31:0] Branch_Address_in,
    input [3:0] Dest_in,
    input [3:0] SR_in,
    input WB_EN_in,
    input MEM_R_EN_in,
    input MEM_W_EN_in,
    input B_in,
    output reg [31:0] PC,
    output reg [31:0] Instruction,
    output reg [31:0] ALU_res,
    output reg [31:0] Val_Rm,
    output reg [31:0] Branch_Address,
    output reg [3:0] Dest,
    output reg [3:0] SR,
    output reg WB_EN,
    output reg MEM_R_EN,
    output reg MEM_W_EN,
    output reg B
);

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            PC <= 32'b0;
            Instruction <= 32'b0;
            ALU_res <= 32'b0;
            Val_Rm <= 32'b0;
            Branch_Address <= 32'b0;
            Dest <= 4'b0;
            SR <= 4'b0;
            WB_EN <= 1'b0;
            MEM_R_EN <= 1'b0;
            MEM_W_EN <= 1'b0;
            B <= 1'b0;
        end
        else if (flush) begin
            PC <= 32'b0;
            Instruction <= 32'b0;
            ALU_res <= 32'b0;
            Val_Rm <= 32'b0;
            Branch_Address <= 32'b0;
            Dest <= 4'b0;
            SR <= 4'b0;
            WB_EN <= 1'b0;
            MEM_R_EN <= 1'b0;
            MEM_W_EN <= 1'b0;
            B <= 1'b0;
        end
        else if (!freeze) begin
            PC <= PC_in;
            Instruction <= Instruction_in;
            ALU_res <= ALU_res_in;
            Val_Rm <= Val_Rm_in;
            Branch_Address <= Branch_Address_in;
            Dest <= Dest_in;
            SR <= SR_in;
            WB_EN <= WB_EN_in;
            MEM_R_EN <= MEM_R_EN_in;
            MEM_W_EN <= MEM_W_EN_in;
            B <= B_in;
        end
    end

endmodule
