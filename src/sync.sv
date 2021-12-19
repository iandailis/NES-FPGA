module sync2(
	input Clk,
	input [1:0] in,
	output [1:0] out
);

always_ff @ (posedge Clk) begin

	out <= in;

end

endmodule

module sync8(
	input Clk,
	input [7:0] in,
	output [7:0] out
);

always_ff @ (posedge Clk) begin

	out <= in;

end

endmodule

module sync10(
	input Clk,
	input [9:0] in,
	output [9:0] out
);

always_ff @ (posedge Clk) begin

	out <= in;

end

endmodule