module part2(Clock, Reset_b, Data, Function, ALUout);
input [3:0]Data;
input [2:0]Function;
input Clock, Reset_b;
output reg [7:0]ALUout;
wire [7:0]ALUout1;

	ALU a1(Data, ALUout[3:0], Function, ALUout1);
	
	always@(posedge Clock)
	begin
		if (Reset_b == 1'b0)
			ALUout <= 8'b0;
		else
			ALUout <= ALUout1;
	end
endmodule



module ALU(A, B, Function, ALUout);
input [3:0]A, B;
input [2:0]Function;
output reg [7:0]ALUout;
wire [7:0]Out;

	case0 c0(A, B, Out);

	always @(*)
	begin 
		case (Function[2:0])
		3'b000: ALUout = Out; //case0
		3'b001: ALUout = A + B; //case1
		3'b010: ALUout = {{4{B[3]}}, B}; //case2
		3'b011: ALUout = |{A, B};//case3
		3'b100: ALUout = &{A, B};//case4
		3'b101: ALUout = {A, B}; //case5
		3'b110: ALUout = A * B; //case6
		3'b111: ALUout = ALUout;
		default: ALUout = 8'b0;//default case
		endcase
	end
	
endmodule



module FullAdder(a, b, c_in, s, c_out);
input a, b, c_in;
output s, c_out;

	assign s = a ^ b ^ c_in;
	assign c_out = a*b + a*c_in + b*c_in;
	
endmodule



module FourBA(a, b, c_in, s, c_out);
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




module case0(input [3:0]A, [3:0]B, output [7:0]Out);
wire [3:0]mid, carry;

	FourBA FBA1(A, B, 1'b0, mid, carry);
	assign Out = {3'b000, carry[3], mid};
	
endmodule
