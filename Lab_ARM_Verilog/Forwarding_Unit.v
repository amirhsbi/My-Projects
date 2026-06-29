module Forwarding_Unit (
    input Forwarding_EN,
    input [3:0] src1,
    input [3:0] src2,
    input Two_src,
    input [3:0] MEM_Dest,
    input MEM_WB_EN,
    input [3:0] WB_Dest,
    input WB_WB_EN,
    output reg [1:0] Sel_Src1,
    output reg [1:0] Sel_Src2
);

    localparam SEL_REG = 2'b00;
    localparam SEL_MEM = 2'b01;
    localparam SEL_WB  = 2'b10;

    always @(*) begin
        Sel_Src1 = SEL_REG;
        Sel_Src2 = SEL_REG;

        if (Forwarding_EN) begin
            if (MEM_WB_EN && (MEM_Dest != 4'd15) && (src1 == MEM_Dest))
                Sel_Src1 = SEL_MEM;
            else if (WB_WB_EN && (WB_Dest != 4'd15) && (src1 == WB_Dest))
                Sel_Src1 = SEL_WB;

            if (Two_src) begin
                if (MEM_WB_EN && (MEM_Dest != 4'd15) && (src2 == MEM_Dest))
                    Sel_Src2 = SEL_MEM;
                else if (WB_WB_EN && (WB_Dest != 4'd15) && (src2 == WB_Dest))
                    Sel_Src2 = SEL_WB;
            end
        end
    end

endmodule
