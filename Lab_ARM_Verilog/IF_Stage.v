module IF_Stage (
    input clk,
    input rst,
    input freeze,
    input Branch_taken,
    input [31:0] BranchAddr,
    output [31:0] PC,
    output [31:0] Instruction
);

    wire [31:0] PCPlus1;
    wire [31:0] NextPC;

    Adder ADDER (
        .in(PC),
        .out(PCPlus1)
    );

    Mux2to1 MUX (
        .in0(PCPlus1),
        .in1(BranchAddr),
        .sel(Branch_taken),
        .out(NextPC)
    );

    PC PC_REGISTER (
        .clk(clk),
        .rst(rst),
        .freeze(freeze),
        .PC_in(NextPC),
        .PC(PC)
    );

    instruction_mem INST_MEM (
        .addr(PC[10:0]),
        .instruction(Instruction)
    );

endmodule
