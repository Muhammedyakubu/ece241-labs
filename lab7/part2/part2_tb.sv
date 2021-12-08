//Tester
//TESTCASES=18
`timescale 1 ns/10 ps 

  module part2_tb ();

   //---------------------------------------------------------
   // inputs to the DUT are reg type

   reg Resetn;
   reg PlotBox;
   reg Black;
   reg LoadX;
   reg [2:0] Colour;
   reg [6:0] XY_Coord;
   reg Clock_50;
   reg Draw;
             
   //--------------------------------------------------------
   // outputs from the DUT are wire type

   wire [7:0] Xout;
   wire [6:0] Yout;
   wire [2:0] ColourOut;
   wire       Plot;
   
   logic plotPass;
   logic ColourPass;
   integer waitTime;

   //---------------------------------------------------------
   // instantiate the Device Under Test (DUT)
   // using named instantiation

        part2 #(.X_SCREEN_PIXELS(8'd8), // Make screen smaller for clear testing
                        .Y_SCREEN_PIXELS(7'd5))   
        U1 (.iResetn(Resetn),
             .iPlotBox(PlotBox),
             .iBlack(Black),
             .iColour(Colour),
             .iLoadX(LoadX),
             .iXY_Coord(XY_Coord),
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

        initial begin
      // $monitor will print whenever a signal changes in the design
      //$monitor($time, "cur_state = %d, iBlack = %d, DrawBox = %d, Xorigin = %d, Yorigin = %d, XDim = %d, YDim = %d, Xout = %d, Yout = %d, ColourOut = %b, Plot = %b", U1.current_state, U1.iBlack, U1.DrawBox, U1.Xorigin, U1.Yorigin, U1.XDim, U1.YDim, Xout, Yout, ColourOut, Plot);
   end

   // Tests
   initial begin
                Clock_50 = 1'b0; // at time 0
                PlotBox = 0;
                Black = 0;
                Colour = 5;
                LoadX = 0;
                XY_Coord = 6'd17;
                ColourPass = 1;
                plotPass = 1;
                waitTime = 0;
                Resetn = 0;  // Put in reset
                $display("At cycle %d, iResetn = %d, iPlotBox = %d, iBlack = %d, iLoadX = %d, iColour = %d, iXY_Coord = %d", $time, 
                        Resetn, PlotBox, Black, LoadX, Colour, XY_Coord);
                #10 Resetn = 1;  // Release reset
                $display("At cycle %d, iResetn = %d, iPlotBox = %d, iBlack = %d, iLoadX = %d, iColour = %d, iXY_Coord = %d", $time, 
                        Resetn, PlotBox, Black, LoadX, Colour, XY_Coord);
                LoadX = 1;
                $display("At cycle %d, iResetn = %d, iPlotBox = %d, iBlack = %d, iLoadX = %d, iColour = %d, iXY_Coord = %d", $time, 
                        Resetn, PlotBox, Black, LoadX, Colour, XY_Coord);
                #5 LoadX = 0;
                $display("At cycle %d, iResetn = %d, iPlotBox = %d, iBlack = %d, iLoadX = %d, iColour = %d, iXY_Coord = %d", $time, 
                        Resetn, PlotBox, Black, LoadX, Colour, XY_Coord);
                #5 XY_Coord = 6'd2;
                $display("At cycle %d, iResetn = %d, iPlotBox = %d, iBlack = %d, iLoadX = %d, iColour = %d, iXY_Coord = %d", $time, 
                        Resetn, PlotBox, Black, LoadX, Colour, XY_Coord);
                #5 PlotBox = 1;
                $display("At cycle %d, iResetn = %d, iPlotBox = %d, iBlack = %d, iLoadX = %d, iColour = %d, iXY_Coord = %d", $time, 
                        Resetn, PlotBox, Black, LoadX, Colour, XY_Coord);
                #5 PlotBox = 0;
                $display("At cycle %d, iResetn = %d, iPlotBox = %d, iBlack = %d, iLoadX = %d, iColour = %d, iXY_Coord = %d", $time, 
                        Resetn, PlotBox, Black, LoadX, Colour, XY_Coord);
                $display("Start drawing a 4x4 box at (17,2) with Colour 5");
                while((Xout !== 17 || Yout !== 2) && waitTime < 20) begin
                        waitTime = waitTime + 1;
                        #1;
                end
                if(waitTime >= 20) begin
                        $display("Wait too long for Xout, Yout to initilize to 17 and 2, check your waveform");
                        $finish;
                end else begin
                        waitTime = 0;
                end
                for (int i = 0; i < 4; i++) begin
                        for (int j = 0; j < 4; j++) begin
                                if(Xout == 17+j && Yout == 2+i) begin
                                        $display("At cycle %d, your oX = %d oY = %d, expect oX = %d oY = %d, PASSED", $time, Xout, Yout, 17+j, 2+i);
                                end else begin
                                        $display("At cycle %d, your oX = %d oY = %d, expect oX = %d oY = %d, FAILED", $time, Xout, Yout, 17+j, 2+i);
                                end
                                if(ColourOut == 5) begin
                                end else begin
                                        $display("At cycle %d, your oColour = %d, expected oColour = 5", $time, ColourOut);
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
                $finish;
        end // initial begin
endmodule // draw4x4box_tb