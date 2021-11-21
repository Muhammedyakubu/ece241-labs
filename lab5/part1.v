module part1(Clock, Enable, Clear_b, CounterValue);
input Clock, Enable, Clear_b;
output reg [7:0] CounterValue;

    always @(posedge Clock) begin
        if (!Clear_b)
            CounterValue <= 0;
        else if (CounterValue == 7'b1111111)
            CounterValue <= 0;
        else if (Enable) 
            CounterValue <= CounterValue + 1;
    end

endmodule