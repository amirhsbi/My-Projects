module ControlUnit (
    input [1:0] mode,
    input [3:0] opcode,
    input S,
    input I,

    output reg [3:0] EXE_CMD,
    output reg MEM_R_EN,
    output reg MEM_W_EN,
    output reg WB_EN,
    output reg imm,
    output reg B,
    output reg S_out
);

    always @(*) begin
        EXE_CMD  = 4'b0000;
        MEM_R_EN = 1'b0;
        MEM_W_EN = 1'b0;
        WB_EN    = 1'b0;
        imm      = I;
        B        = 1'b0;
        S_out    = 1'b0;

        case (mode)
            2'b00: begin
                S_out = S;

                case (opcode)
                    4'b1101: begin
                        EXE_CMD = 4'b0001;   
                        WB_EN   = 1'b1;
                    end

                    4'b1111: begin
                        EXE_CMD = 4'b1001;   
                        WB_EN   = 1'b1;
                    end

                    4'b0100: begin
                        EXE_CMD = 4'b0010;  
                        WB_EN   = 1'b1;
                    end

                    4'b0101: begin
                        EXE_CMD = 4'b0011;   
                        WB_EN   = 1'b1;
                    end

                    4'b0010: begin
                        EXE_CMD = 4'b0100;   
                        WB_EN   = 1'b1;
                    end

                    4'b0110: begin
                        EXE_CMD = 4'b0101;  
                        WB_EN   = 1'b1;
                    end

                    4'b0000: begin
                        EXE_CMD = 4'b0110;   
                        WB_EN   = 1'b1;
                    end

                    4'b1100: begin
                        EXE_CMD = 4'b0111;   
                        WB_EN   = 1'b1;
                    end

                    4'b0001: begin
                        EXE_CMD = 4'b1000;   
                        WB_EN   = 1'b1;
                    end

                    4'b1010: begin
                        EXE_CMD = 4'b0100;   
                        WB_EN   = 1'b0;
                    end

                    4'b1000: begin
                        EXE_CMD = 4'b0110;   
                        WB_EN   = 1'b0;
                    end

                    default: begin
                        EXE_CMD = 4'b0000;
                        WB_EN   = 1'b0;
                        S_out   = 1'b0;
                    end
                endcase
            end

            2'b01: begin
                EXE_CMD = 4'b0010;   
                S_out   = 1'b0;

                if (S == 1'b1) begin
                    MEM_R_EN = 1'b1; 
                    MEM_W_EN = 1'b0;
                    WB_EN    = 1'b1;
                end
                else begin
                    MEM_R_EN = 1'b0;
                    MEM_W_EN = 1'b1; 
                    WB_EN    = 1'b0;
                end
            end

            2'b10: begin
                EXE_CMD  = 4'b0000;  
                MEM_R_EN = 1'b0;
                MEM_W_EN = 1'b0;
                WB_EN    = 1'b0;
                imm      = 1'b0;
                B        = 1'b1;
                S_out    = 1'b0;
            end

            default: begin
                EXE_CMD  = 4'b0000;
                MEM_R_EN = 1'b0;
                MEM_W_EN = 1'b0;
                WB_EN    = 1'b0;
                imm      = 1'b0;
                B        = 1'b0;
                S_out    = 1'b0;
            end
        endcase
    end

endmodule
