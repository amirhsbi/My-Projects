module ConditionCheck (
    input [3:0] cond,
    input [3:0] SR,
    output reg condition_passed
);

    wire N;
    wire Z;
    wire C;
    wire V;

    assign N = SR[3];
    assign Z = SR[2];
    assign C = SR[1];
    assign V = SR[0];

    always @(*) begin
        case (cond)
            4'b0000: condition_passed = Z;
            4'b0001: condition_passed = ~Z;
            4'b0010: condition_passed = C;
            4'b0011: condition_passed = ~C;
            4'b0100: condition_passed = N;
            4'b0101: condition_passed = ~N;
            4'b0110: condition_passed = V;
            4'b0111: condition_passed = ~V;
            4'b1000: condition_passed = C & ~Z;
            4'b1001: condition_passed = ~C | Z;
            4'b1010: condition_passed = (N == V);
            4'b1011: condition_passed = (N != V);
            4'b1100: condition_passed = (~Z) & (N == V);
            4'b1101: condition_passed = Z | (N != V);
            4'b1110: condition_passed = 1'b1;
            4'b1111: condition_passed = 1'b0;
            default: condition_passed = 1'b0;
        endcase
    end

endmodule
