module part3(clock, reset, ParallelLoadn, RotateRight, ASRight, Data_IN, Q);
input clock, reset, ParallelLoadn, RotateRight, ASRight;
input [7:0]Data_IN;
output reg [7:0]Q;

	always@(posedge clock)
	begin
		if(reset == 1)//reset
			Q <= 8'b0;
		else if(ParallelLoadn == 0)//case1
			Q <= Data_IN;
		else if((ParallelLoadn == 1) & (RotateRight == 1) & (ASRight == 0))//case2
			begin
				Q[7] <= Q[0];
				Q[6] <= Q[7];
				Q[5] <= Q[6];
				Q[4] <= Q[5];
				Q[3] <= Q[4];
				Q[2] <= Q[3];
				Q[1] <= Q[2];
				Q[0] <= Q[1];
			end
		else if((ParallelLoadn == 1) & (RotateRight == 1) & (ASRight == 1))
			begin 
				Q[7] <= Q[7];
				Q[6] <= Q[7];
				Q[5] <= Q[6];
				Q[4] <= Q[5];
				Q[3] <= Q[4];
				Q[2] <= Q[3];
				Q[1] <= Q[2];
				Q[0] <= Q[1];
			end
		else if((ParallelLoadn == 1) & (RotateRight == 0))
			begin
				Q[7] <= Q[6];
				Q[6] <= Q[5];
				Q[5] <= Q[4];
				Q[4] <= Q[3];
				Q[3] <= Q[2];
				Q[2] <= Q[1];
				Q[1] <= Q[0];
				Q[0] <= Q[7];
			end
	end

endmodule

//module sub_circuit?