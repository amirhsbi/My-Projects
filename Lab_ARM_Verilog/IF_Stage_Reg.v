module IF_Stage_Reg (
    input clk,
    input rst,
    input freeze,
    input flush,
    input [31:0] PC_in,
    input [31:0] Instruction_in,
    output reg [31:0] PC,
    output reg [31:0] Instruction
);

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            PC <= 32'b0;
            Instruction <= 32'b0;
        end
        else if (flush) begin
            PC <= 32'b0;
            Instruction <= 32'b0;
        end
        else if (!freeze) begin
            PC <= PC_in;
            Instruction <= Instruction_in;
        end
    end

endmodule
