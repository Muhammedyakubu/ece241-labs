//
// This is the template for Part 3 of Lab 7.
//
// Paul Chow
// November 2021
//

// iColour is the colour for the box
//
// oX, oY, oColour and oPlot should be wired to the appropriate ports on the VGA controller
//

// Some constants are set as parameters to accommodate the different implementations
// X_SCREENSIZE, Y_SCREENSIZE are the dimensions of the screen
//       Default is 160 x 120, which is size for fake_fpga and baseline for the DE1_SoC vga controller
// CLOCKS_PER_SECOND should be the frequency of the clock being used.

module part3(iColour,iResetn,iClock,oX,oY,oColour,oPlot);
   input wire [2:0] iColour;
   input wire 	    iResetn;
   input wire 	    iClock;
   output wire [7:0] oX;         // VGA pixel coordinates
   output wire [6:0] oY;
   
   output wire [2:0] oColour;     // VGA pixel colour (0-7)
   output wire 	     oPlot;       // Pixel drawn enable

   parameter
   X_SCREENSIZE = 160,  // X screen width for starting resolution and fake_fpga
   Y_SCREENSIZE = 120,  // Y screen height for starting resolution and fake_fpga
   CLOCKS_PER_SECOND = 5000, // 5 KHZ for fake_fpga - changed to 40 for testing
   X_BOXSIZE = 8'd4,   // Box X dimension
   Y_BOXSIZE = 7'd4,   // Box Y dimension
   X_MAX = X_SCREENSIZE - 1 - X_BOXSIZE, // 0-based and account for box width
   Y_MAX = Y_SCREENSIZE - 1 - Y_BOXSIZE,
   PULSES_PER_SIXTIETH_SECOND = CLOCKS_PER_SECOND / 60;

   reg [3:0] counter, frameCounter;
   reg [20:0] delayCounter;
   wire counter_en, delayCounter_en, update_coord;
   wire [1:0] DirH, DirY;
   
   // counters
   always@(posedge iClock)
   begin: counters

      //delayCounter
      if (!iResetn || delayCounter == CLOCKS_PER_SECOND/4 - 1)
         delayCounter <= 0;
      else if (delayCounter_en)
         delayCounter <= delayCounter + 1;

      //FrameCounter
      if (!iResetn || frameCounter == 4'b1111)
         frameCounter <= 0;
      else if (delayCounter == CLOCKS_PER_SECOND/4 - 1)
         frameCounter <= frameCounter + 1;

      //position counter
      if (!iResetn || frameCounter == 4'b1111)
         counter <= 0;
      else if (counter_en)
         counter <= counter + 1; 

   end

   control # (
      .X_MAX(X_MAX),
      .Y_MAX(Y_MAX)
   ) C0 (
      .iColour(iColour),
      .iResetn(iResetn),
      .iClock(iClock),
      .counter(counter),
      .frameCounter(frameCounter),
      .oX(oX),
      .oY(oY),

      .counter_en(counter_en),
      .delayCounter_en(delayCounter_en),
      .DirH(DirH),
      .DirY(DirY),
      .oColour(oColour),
      .oPlot(oPlot),
      .update_coord(update_coord)
   );

   datapath D0(
      .iClock(iClock),
      .iResetn(iResetn),
      .oPlot(oPlot),
      .update_coord(update_coord),
      .DirH(DirH),
      .DirY(DirY),
      .oColour(oColour),
      .counter(counter),

      .oX(oX),
      .oY(oY)
   );

endmodule // part3

module control (
   input [2:0] iColour,
   input iResetn,
   input iClock,
   input [3:0] counter,
   input [3:0] frameCounter,
   input [7:0] oX,         
   input [6:0] oY,

   output reg counter_en, delayCounter_en,
   output reg [1:0] DirH, DirY,
   output reg [2:0] oColour,
   output reg oPlot, update_coord
);
   parameter
   X_MAX = 155,
   Y_MAX = 115;
   
   reg [3:0] current_state, next_state; 
    
   localparam  S_DRAW           = 5'd0,
               S_DRAW_WAIT      = 5'd1,
               S_ERASE          = 5'd2,
               S_UPDATE         = 5'd3;

   always@(*)
   begin: state_table
      case (current_state)
         S_DRAW: next_state = (counter == 4'b1111) ? S_DRAW_WAIT : S_DRAW;
         S_DRAW_WAIT: next_state = (frameCounter == 15) ? S_ERASE : S_DRAW_WAIT;
         S_ERASE: next_state = (counter == 4'b1111) ? S_UPDATE : S_ERASE;
         S_UPDATE: next_state = S_DRAW;
         default: next_state = S_DRAW;
      endcase
   end

   always @(*) 
   begin: enable_signals
      //by default make all our signals 0
      counter_en = 0;
      delayCounter_en = 0;
      DirH = 1;
      DirY = 0;
      oColour = 3'b0;
      oPlot = 0;
      update_coord = 0;

      case (current_state)
         S_DRAW: begin
            counter_en = 1;
            oPlot = 1;
            oColour = iColour;
         end
         S_DRAW_WAIT: begin
            delayCounter_en = 1;
         end
         S_ERASE: begin
            counter_en = 1;
            oPlot = 1;
            oColour = 3'b0;
         end
         S_UPDATE: begin
            update_coord = 1;
            if (oX >= X_MAX) 
               DirH = 0;
            else if (oX <= 0)
               DirH = 1;

            if (oY >= Y_MAX) 
               DirY = 1;
            else if (oY <= 0)
               DirY = 0;
         end
      endcase
   end
   
   always @(posedge iClock) 
   begin: state_FFs
      if (!iResetn)
         current_state <= S_DRAW;
      else 
         current_state <= next_state;
   end


endmodule


module datapath (
   input iClock,
   input iResetn,
   input oPlot,
   input update_coord,
   input [1:0] DirH, DirY,
   input [2:0] oColour,
   input [3:0] counter,

   output reg [7:0] oX,
   output reg [6:0] oY
);
   reg [7:0] x_init;
   reg [6:0] y_init;

   always @(posedge update_coord) 
   begin: update_coordinates
      if (!iResetn) begin
         x_init <= 0;
         y_init <= 0;
      end
      else begin
         if (DirH)
            x_init <= x_init + 1;
         else if (!DirH)
            x_init <= x_init - 1;

         if (DirY)
            y_init <= y_init - 1;
         else if (!DirY)
            y_init <= y_init + 1;
      end
   end

   //Plotting
   always @(posedge iClock) begin: plot // I can get it on sync if i change sensitivity list to @(*)
      if (!iResetn) begin
         //oX <= 0;
         //oY <= 0;
         x_init <= 0;
         y_init <= 0;
      end
      else if(oPlot) begin
         oX <= x_init + counter[1:0];
         oY <= y_init + counter[3:2];
      end   
   end

endmodule