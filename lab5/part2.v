module part2(ClockIn, Reset, Speed, CounterValue);
input ClockIn, Reset;
input [1:0] Speed;
output reg [3:0] CounterValue;
wire EnableDC;
reg [30:0] RateDivider;
parameter [30:0] fpga = 50_000_000, auto = 500, test = 5;

    assign EnableDC = (RateDivider == 31'b0)?1:0;

    always @(posedge ClockIn) begin
    //RateDivider
	if (Reset)
		RateDivider <= 0;
	else if (RateDivider == 0) begin
		case (Speed)
			2'b00: RateDivider <= 0;
			2'b01: RateDivider <= auto - 1;
			2'b10: RateDivider <= 2 * auto - 1;
			2'b11: RateDivider <= 4 * auto - 1;
			default: RateDivider <= 0;
		endcase
	end
	else
		RateDivider <= RateDivider - 1;

    //DisplayCounter
	if(Reset || CounterValue == 4'b1111)
		CounterValue <= 0;
	else if(EnableDC)
		CounterValue <= CounterValue + 1;
    end

endmodule