module WB_Stage (
    input [31:0] PC_in,
    input [31:0] Instruction_in,
    input [31:0] ALU_res_in,
    input [31:0] Data_Mem_out_in,
    input [3:0] Dest_in,
    input WB_EN_in,
    input MEM_R_EN_in,
    output reg [31:0] PC,
    output reg [31:0] Instruction,
    output [31:0] WB_Value,
    output [3:0] WB_Dest,
    output WB_EN
);

    assign WB_Value = MEM_R_EN_in ? Data_Mem_out_in : ALU_res_in;
    assign WB_Dest = Dest_in;
    assign WB_EN = WB_EN_in;

    always @(*) begin
        PC = PC_in;
        Instruction = Instruction_in;
    end

endmodule
