module Val2Generator (
    input [31:0] Val_Rm,
    input [11:0] shift_operand,
    input imm,
    input MEM_R_EN,
    input MEM_W_EN,
    output reg [31:0] Val2
);

    wire is_memory;
    wire [31:0] memory_offset;
    wire [31:0] immed_value;
    wire [31:0] rotated_immed;
    wire [5:0] rotate_amount;

    assign is_memory = MEM_R_EN | MEM_W_EN;
    assign memory_offset = {{20{shift_operand[11]}}, shift_operand};
    assign immed_value = {24'b0, shift_operand[7:0]};
    assign rotate_amount = {1'b0, shift_operand[11:8], 1'b0};
    assign rotated_immed = (rotate_amount == 6'd0) ? immed_value : ((immed_value >> rotate_amount[4:0]) | (immed_value << (6'd32 - rotate_amount)));

    always @(*) begin
        if (is_memory)
            Val2 = memory_offset;
        else if (imm)
            Val2 = rotated_immed;
        else
            Val2 = Val_Rm;
    end

endmodule
