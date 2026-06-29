module Adder (
    input [31:0] in,
    output [31:0] out
);

    assign out = in + 32'd1;

endmodule
