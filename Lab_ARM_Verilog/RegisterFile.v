module RegisterFile (
    input clk,
    input rst,
    input [3:0] src_1,
    input [3:0] src_2,
    input [3:0] Dest_WB,
    input [31:0] Result_WB,
    input writeBackEN,
    output [31:0] reg_out_1,
    output [31:0] reg_out_2
);

    reg [31:0] registers [0:14];
    integer i;

    initial begin
        for (i = 0; i < 15; i = i + 1)
            registers[i] = i;
    end

    assign reg_out_1 = (src_1 < 4'd15) ? registers[src_1] : 32'b0;
    assign reg_out_2 = (src_2 < 4'd15) ? registers[src_2] : 32'b0;

    always @(negedge clk or posedge rst) begin
        if (rst) begin
            for (i = 0; i < 15; i = i + 1)
                registers[i] <= i;
        end
        else begin
            if (writeBackEN && (Dest_WB < 4'd15))
                registers[Dest_WB] <= Result_WB;
        end
    end

endmodule
