module FullAdder(a, b, c_in, s, c_out);
input a, b, c_in;
output s, c_out;

	assign s = a ^ b ^ c_in;
	assign c_out = (a & b) | (a & c_in) | (b & c_in);
	
endmodule 

module part2(a, b, c_in, s, c_out);
input [3:0]a, b;
input c_in;
output [3:0]s, c_out;
wire [2:0]c;

	FullAdder u0(a[0], b[0], c_in, s[0], c[0]);
	FullAdder u1(a[1], b[1], c[0], s[1], c[1]);
	FullAdder u2(a[2], b[2], c[1], s[2], c[2]);
	FullAdder u3(a[3], b[3], c[2], s[3], c_out[3]);
	assign c_out[2] = c[2];
	assign c_out[1] = c[1];
	assign c_out[0] = c[0];

endmodule