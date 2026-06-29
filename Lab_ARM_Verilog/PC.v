module PC (
    input clk,
    input rst,
    input freeze,
    input [31:0] PC_in,
    output reg [31:0] PC
);

    always @(posedge clk or posedge rst) begin
        if (rst)
            PC <= 32'b0;
        else if (!freeze)
            PC <= PC_in;
    end

endmodule
