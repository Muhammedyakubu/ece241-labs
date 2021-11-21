module part3(ClockIn, Resetn, Start, Letter, DotDashOut);
input ClockIn, Resetn, Start;
input [2:0] Letter;
output reg DotDashOut;
reg [11:0] shift_reg;
reg [30:0] RateDivider;
wire Enable;
parameter [30:0] fpga = 50_000_000, auto = 500, test = 4;

    assign Enable = (RateDivider == 30'b0)?1:0;	

    always @(posedge ClockIn, negedge Resetn) begin
        //RateDivider
        if (!Resetn || !RateDivider)
            RateDivider <= auto/2 - 1;
        else
            RateDivider <= RateDivider - 1;

        //Moorse Code Module
        if (!Resetn)
            shift_reg <= 0;
        else if (Start) begin
            case (Letter)
                3'b000: shift_reg <= 12'b10111_0000000;
                3'b001: shift_reg <= 12'b111010101_000;
                3'b010: shift_reg <= 12'b11101011101_0;
                3'b011: shift_reg <= 12'b1110101_00000;
                3'b100: shift_reg <= 12'b1_00000000000;
                3'b101: shift_reg <= 12'b101011101_000;
                3'b110: shift_reg <= 12'b1110111101_00;
                3'b111: shift_reg <= 12'b1010101_00000;
                default:  shift_reg <= 12'b0;
		    endcase
        end
        else if(Enable) begin
            DotDashOut <= shift_reg[11];
            shift_reg <= shift_reg << 1;
            shift_reg[0] <= shift_reg[11];
        end
    end
endmodule
