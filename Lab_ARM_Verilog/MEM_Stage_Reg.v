module MEM_Stage_Reg (
    input clk,
    input rst,
    input freeze,
    input flush,
    input [31:0] PC_in,
    input [31:0] Instruction_in,
    input [31:0] ALU_res_in,
    input [31:0] Data_Mem_out_in,
    input [3:0] Dest_in,
    input WB_EN_in,
    input MEM_R_EN_in,
    output reg [31:0] PC,
    output reg [31:0] Instruction,
    output reg [31:0] ALU_res,
    output reg [31:0] Data_Mem_out,
    output reg [3:0] Dest,
    output reg WB_EN,
    output reg MEM_R_EN
);

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            PC <= 32'b0;
            Instruction <= 32'b0;
            ALU_res <= 32'b0;
            Data_Mem_out <= 32'b0;
            Dest <= 4'b0;
            WB_EN <= 1'b0;
            MEM_R_EN <= 1'b0;
        end
        else if (flush) begin
            PC <= 32'b0;
            Instruction <= 32'b0;
            ALU_res <= 32'b0;
            Data_Mem_out <= 32'b0;
            Dest <= 4'b0;
            WB_EN <= 1'b0;
            MEM_R_EN <= 1'b0;
        end
        else if (!freeze) begin
            PC <= PC_in;
            Instruction <= Instruction_in;
            ALU_res <= ALU_res_in;
            Data_Mem_out <= Data_Mem_out_in;
            Dest <= Dest_in;
            WB_EN <= WB_EN_in;
            MEM_R_EN <= MEM_R_EN_in;
        end
    end

endmodule
