module ALU (
    input [31:0] in1,
    input [31:0] in2,
    input [3:0] EXE_CMD,
    input C_in,
    output reg [31:0] result,
    output reg [3:0] status
);

    reg [32:0] temp;
    reg C;
    reg V;

    always @(*) begin
        result = 32'b0;
        C = 1'b0;
        V = 1'b0;
        temp = 33'b0;

        case (EXE_CMD)
            4'b0001: begin
                result = in2;
            end
            4'b1001: begin
                result = ~in2;
            end
            4'b0010: begin
                temp = {1'b0, in1} + {1'b0, in2};
                result = temp[31:0];
                C = temp[32];
                V = (~in1[31] & ~in2[31] & result[31]) | (in1[31] & in2[31] & ~result[31]);
            end
            4'b0011: begin
                temp = {1'b0, in1} + {1'b0, in2} + C_in;
                result = temp[31:0];
                C = temp[32];
                V = (~in1[31] & ~in2[31] & result[31]) | (in1[31] & in2[31] & ~result[31]);
            end
            4'b0100: begin
                temp = {1'b0, in1} - {1'b0, in2};
                result = temp[31:0];
                C = ~temp[32];
                V = (~in1[31] & in2[31] & result[31]) | (in1[31] & ~in2[31] & ~result[31]);
            end
            4'b0101: begin
                temp = {1'b0, in1} - {1'b0, in2} - {32'b0, ~C_in};
                result = temp[31:0];
                C = ~temp[32];
                V = (~in1[31] & in2[31] & result[31]) | (in1[31] & ~in2[31] & ~result[31]);
            end
            4'b0110: begin
                result = in1 & in2;
            end
            4'b0111: begin
                result = in1 | in2;
            end
            4'b1000: begin
                result = in1 ^ in2;
            end
            default: begin
                result = 32'b0;
            end
        endcase

        status[3] = result[31];
        status[2] = (result == 32'b0);
        status[1] = C;
        status[0] = V;
    end

endmodule
