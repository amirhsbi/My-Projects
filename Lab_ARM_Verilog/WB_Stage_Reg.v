module WB_Stage_Reg (
    input clk,
    input rst,
    input freeze,
    input flush,
    input [31:0] PC_in,
    input [31:0] Instruction_in,
    input [31:0] WB_Value_in,
    input [3:0] WB_Dest_in,
    input WB_EN_in,
    output reg [31:0] PC,
    output reg [31:0] Instruction,
    output reg [31:0] WB_Value,
    output reg [3:0] WB_Dest,
    output reg WB_EN
);

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            PC <= 32'b0;
            Instruction <= 32'b0;
            WB_Value <= 32'b0;
            WB_Dest <= 4'b0;
            WB_EN <= 1'b0;
        end
        else if (flush) begin
            PC <= 32'b0;
            Instruction <= 32'b0;
            WB_Value <= 32'b0;
            WB_Dest <= 4'b0;
            WB_EN <= 1'b0;
        end
        else if (!freeze) begin
            PC <= PC_in;
            Instruction <= Instruction_in;
            WB_Value <= WB_Value_in;
            WB_Dest <= WB_Dest_in;
            WB_EN <= WB_EN_in;
        end
    end

endmodule
