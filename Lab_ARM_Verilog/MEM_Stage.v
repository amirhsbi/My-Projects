module MEM_Stage (
    input clk,
    input [31:0] PC_in,
    input [31:0] Instruction_in,
    input [31:0] ALU_res_in,
    input [31:0] Val_Rm_in,
    input [3:0] Dest_in,
    input WB_EN_in,
    input MEM_R_EN_in,
    input MEM_W_EN_in,
    output reg [31:0] PC,
    output reg [31:0] Instruction,
    output [31:0] ALU_res,
    output [31:0] Val_Rm,
    output [31:0] Data_Mem_out,
    output [3:0] Dest,
    output WB_EN,
    output MEM_R_EN,
    output MEM_W_EN
);

    data_mem DATA_MEMORY (
        .clk(clk),
        .MEM_R_EN(MEM_R_EN_in),
        .MEM_W_EN(MEM_W_EN_in),
        .addr(ALU_res_in),
        .write_data(Val_Rm_in),
        .read_data(Data_Mem_out)
    );

    assign ALU_res = ALU_res_in;
    assign Val_Rm = Val_Rm_in;
    assign Dest = Dest_in;
    assign WB_EN = WB_EN_in;
    assign MEM_R_EN = MEM_R_EN_in;
    assign MEM_W_EN = MEM_W_EN_in;

    always @(*) begin
        PC = PC_in;
        Instruction = Instruction_in;
    end

endmodule
