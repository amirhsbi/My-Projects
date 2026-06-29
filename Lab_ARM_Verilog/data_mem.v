module data_mem (
    input clk,
    input MEM_R_EN,
    input MEM_W_EN,
    input [31:0] addr,
    input [31:0] write_data,
    output [31:0] read_data
);

    reg [31:0] mem [0:2047];
    integer i;

    initial begin
        for (i = 0; i < 2048; i = i + 1)
            mem[i] = 32'b0;
    end

    assign read_data = MEM_R_EN ? mem[addr[10:0]] : 32'b0;

    always @(posedge clk) begin
        if (MEM_W_EN)
            mem[addr[10:0]] <= write_data;
    end

endmodule
