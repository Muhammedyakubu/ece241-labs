//Tester
//TESTCASES=35
`timescale 1 ns/10 ps 

  module part3_tb ();

   //---------------------------------------------------------
   // inputs to the DUT are reg type

  reg Clock_50;
  reg [2:0] Colour;
  reg 	     Resetn;
 	     
   //--------------------------------------------------------
   // outputs from the DUT are wire type

  wire [7:0] Xout;
  wire [6:0] Yout;
  wire [2:0] ColourOut;
  wire       Plot;

  logic xGolden;
  logic yGolden;
  logic plotPass;
  logic ColourPass;
  integer waitTime;
   

   //---------------------------------------------------------
   // instantiate the Device Under Test (DUT)
   // using named instantiation

   part3 #(.X_SCREENSIZE(9),  // reduce screen size for simulation
	   .Y_SCREENSIZE(7),
	   .CLOCKS_PER_SECOND(1200))  // reduce clock rate for simulation
          U1 (  .iColour(Colour),
		.iResetn(Resetn),
		.iClock(Clock_50),
		.oX(Xout),
		.oY(Yout),
		.oColour(ColourOut),
		.oPlot(Plot)
		);
   
   
   //----------------------------------------------------------
   // create a 50Mhz clock
   always
     #0.5 Clock_50 = ~Clock_50; // every ten nanoseconds invert
   //-----------------------------------------------------------

  // Tests
  initial begin
    Clock_50 = 1'b0; // at time 0
    Colour = 3;
    Resetn = 0;  // In Reset
    xGolden = 0;
    yGolden = 0;
    ColourPass = 1;
		plotPass = 1;
		waitTime = 0;
    $display("At cycle %d, iResetn = %d, iColour = %d", $time, Resetn, Colour);
    #20  Resetn = 1;  // Start drawing
    $display("At cycle %d, iResetn = %d, iColour = %d", $time, Resetn, Colour);
    while((Xout !== 0 || Yout !== 0) && waitTime < 20) begin
      waitTime = waitTime + 1;
      #1;
    end
		if(waitTime >= 20) begin
			$display("Wait too long for Xout, Yout to initilize to 0 and 0, check your waveform");
			$finish;
		end else begin
			waitTime = 0;
		end
    $display("Check for drawing a box, current at frame 0");
    for (int i = 0; i < 4; i++) begin
			for (int j = 0; j < 4; j++) begin
				if(Xout == j && Yout == i) begin
					$display("At cycle %d, your oX = %d oY = %d, expect oX = %d oY = %d, PASSED", $time, Xout, Yout, j, i);
				end else begin
					$display("At cycle %d, your oX = %d oY = %d, expect oX = %d oY = %d, FAILED", $time, Xout, Yout, j, i);
				end
				if(ColourOut == 3) begin
				end else begin
					$display("At cycle %d, your oColour = %d, expected oColour = 3", $time, ColourOut);
					ColourPass = 0;
				end
				if(Plot == 1) begin
				end else begin
					$display("At cycle %d, your oPlot = %d, expected oPlot = 1", $time, Plot);
					plotPass = 0;
				end
				#1;
			end
		end
    if(ColourPass) begin
			$display("At cycle %d, oColour is correct for drawing the box, PASSED", $time);
		end else begin
			$display("At cycle %d, oColour is not correct for drawing the box, FAILED", $time);
		end
		if(plotPass) begin
			$display("At cycle %d, oPlot is correct for drawing the box, PASSED", $time);
		end else begin
			$display("At cycle %d, oPlot is not correct for drawing the box, FAILED", $time);
		end
    for (int i = 1; i < 15; i++) begin
      $display("Check frame %d", i);
      #20;
      if(Xout == 3 && Yout == 3) begin
        $display("At cycle %d, your oX = %d oY = %d, expect oX = %d oY = %d, PASSED", $time, Xout, Yout, 3, 3);
      end else begin
        $display("At cycle %d, your oX = %d oY = %d, expect oX = %d oY = %d, FAILED", $time, Xout, Yout, 3, 3);
      end
    end
    for (int i = 0; i < 3; i++) begin
      $display("Check for coordinate update");
      while((Xout !== i || Yout !== i) && waitTime < 60) begin
        waitTime = waitTime + 1;
        #1;
      end
      if(waitTime >= 60) begin
        $display("At cycle %d, Wait too long for Xout, Yout to initilize to %d and %d, FAILED", $time, i, i);
      end else begin
        $display("At cycle %d, Xout, Yout is initilized to %d and %d, PASSED", $time, i, i);
        waitTime = 0;
      end
      end
      $finish;
  end // initial begin

endmodule // part3_tb



