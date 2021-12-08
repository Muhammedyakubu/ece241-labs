//
// This is the template for Part 2 of Lab 7.
//
// Paul Chow
// November 2021
//

module part2(iResetn,iPlotBox,iBlack,iColour,iLoadX,iXY_Coord,iClock,oX,oY,oColour,oPlot);
   parameter X_SCREEN_PIXELS = 8'd160;
   parameter Y_SCREEN_PIXELS = 7'd120;
   
   input wire iResetn, iPlotBox, iBlack, iLoadX;
   input wire [2:0] iColour;
   input wire [6:0] iXY_Coord;
   input wire iClock;
   output wire [7:0] oX;         // VGA pixel coordinates
   output wire [6:0] oY;
   
   output wire [2:0] oColour;     // VGA pixel colour (0-7)
   output wire 	     oPlot;       // Pixel draw enable


   wire ld_x, ld_y, counter_en, clr_enable;
   wire DONE, DONE_CLR;
   // x and y coordinate registers
   wire [6:0] x_coord, y_coord;
   wire [3:0] counter;
   wire [14:0] clr_counter;

   control C0(
      .iClock(iClock),
      .iResetn(iResetn),
      .iPlotBox(iPlotBox),
      .iColour(iColour),
      .iBlack(iBlack),
      .iLoadX(iLoadX),
      .DONE(DONE),
      .DONE_CLR(DONE_CLR),

      .ld_x(ld_x),
      .ld_y(ld_y),
      .colour(oColour),
      .counter_en(counter_en),
      .clr_enable(clr_enable),
      .oPlot(oPlot)
   );
   
   datapath #(
      .X_SCREEN_PIXELS(X_SCREEN_PIXELS),
      .Y_SCREEN_PIXELS(Y_SCREEN_PIXELS)
   ) D0 (
      .iClock(iClock),
      .iResetn(iResetn),
      .oPlot(oPlot),
      .iBlack(iBlack),
      .iXY_Coord(iXY_Coord),
      .ld_x(ld_x),
      .ld_y(ld_y),
      .colour(oColour),
      .counter_en(counter_en),
      .clr_enable(clr_enable),


      .x_coord(x_coord),
      .y_coord(y_coord),
      .counter(counter),
      .clr_counter(clr_counter),
      .oX(oX),
      .oY(oY),
      .DONE(DONE),
      .DONE_CLR(DONE_CLR)
   );

   
endmodule // part2


module datapath /* #(
   X_SCREEN_PIXELS,
   Y_SCREEN_PIXELS
) */ (
    input iClock,
    input iResetn,
    input oPlot, iBlack,
    input [6:0] iXY_Coord,
    input ld_x, ld_y,
    input [2:0] colour,
    input counter_en, clr_enable,


    output reg [6:0] x_coord, y_coord,
    output reg [3:0] counter,
    output reg [14:0] clr_counter,
    output reg [7:0] oX,
    output reg [6:0] oY,
    output reg DONE, DONE_CLR
    );
   parameter X_SCREEN_PIXELS = 8'd160;
   parameter Y_SCREEN_PIXELS = 7'd120;

   always@(posedge iClock) begin
      if (~iResetn) begin
         x_coord <= 7'b0;
         y_coord <= 7'b0;
         counter <= 4'b0;
         clr_counter <= 15'b0;
      end
      else begin
         if(ld_x)
            x_coord <= iXY_Coord;
         if(ld_y) begin
            y_coord <= iXY_Coord;
         end
         if(iBlack) begin
            x_coord <= 0;
            y_coord <= 0;
         end
      end
   end
   
   
   //implementing the counters
   always@(posedge iClock) begin

      //counter for plotting boxes
      
      if(~iResetn || counter == 4'b1111)
         counter <= 0;
      else if (counter_en)
         counter <= counter + 1;


      //counter for clearing the screen
      
      if(~iResetn || clr_counter == (X_SCREEN_PIXELS * Y_SCREEN_PIXELS))
         clr_counter <= 0;
      else if (clr_enable)
         clr_counter <= clr_counter + 1;


      if (counter == 4'b1111)
         DONE = 1;
      else 
         DONE = 0;


      if (clr_counter == (X_SCREEN_PIXELS * Y_SCREEN_PIXELS))
         DONE_CLR = 1;
      else 
         DONE_CLR = 0;

      /* if (!Resetn)
         oX <= 0;
      else if (x_coord + counter[1:0] + clr_counter[7:0] <= X_SCREEN_PIXELS)
         oX = x_coord + counter[1:0] + clr_counter[7:0];
      else 
         oX = X_SCREEN_PIXELS;

      if (!Resetn)
         oY <= 0;
      else if (y_coord + counter[3:2] + clr_counter[14:8] <= Y_SCREEN_PIXELS)
         oY = y_coord + counter[3:2] + clr_counter[14:8];
      else 
         oY = Y_SCREEN_PIXELS; */

   end

   always@(posedge iClock)
   begin
      if (oPlot) begin
         if (x_coord + counter[1:0] + clr_counter[7:0] <= X_SCREEN_PIXELS)
            oX = x_coord + counter[1:0] + clr_counter[7:0];
         else 
            oX = X_SCREEN_PIXELS;

         if (y_coord + counter[3:2] + clr_counter[14:8] <= Y_SCREEN_PIXELS)
            oY = y_coord + counter[3:2] + clr_counter[14:8];
         else 
            oY = Y_SCREEN_PIXELS;
      end
   end


endmodule

module control(
    input iClock,
    input iResetn,
    input iPlotBox,
    input [2:0] iColour, 
    input iBlack, iLoadX,
    input DONE, DONE_CLR,

    output reg ld_x,ld_y,
    output reg [2:0] colour,
    output reg  counter_en, clr_enable, oPlot
    );

   reg [3:0] current_state, next_state; 
    
   localparam  S_LOAD_X        = 5'd0,
               S_LOAD_X_WAIT   = 5'd1,
               S_LOAD_Y        = 5'd2,
               S_DRAW          = 5'd3,
               S_CLEAR         = 5'd4;

   always@(*)
   begin: state_table
      /* if (iBlack) begin
         current_state = S_CLEAR;
         next_state = S_DONE;
      end
      else  */begin      
         case (current_state)
            S_LOAD_X: next_state = iLoadX ? S_LOAD_X : (iBlack ? S_CLEAR : S_LOAD_X_WAIT);
            S_LOAD_X_WAIT: next_state = iPlotBox ? S_LOAD_Y : S_LOAD_X_WAIT;
            S_LOAD_Y: next_state = iPlotBox == 0 ? S_DRAW : S_LOAD_Y;
            S_DRAW: next_state = DONE ? S_LOAD_X : S_DRAW;
            S_CLEAR: next_state = DONE_CLR ? S_LOAD_X : S_CLEAR;
            default: next_state = S_LOAD_X;
         endcase
      end
   end
   
   always @(*) 
   begin: enable_signals
      //By default make all our signals 0
      ld_x = 0;
      ld_y = 0;
      colour = 3'b0;
      counter_en = 0;
      clr_enable = 0;
      oPlot = 0;

      case (current_state)
         S_LOAD_X: begin
            ld_x = 1;
         end
         S_LOAD_Y: begin
            ld_y = 1;
         end
         S_DRAW: begin
            counter_en = 1;
            oPlot = 1;
            colour = iColour;
         end
         S_CLEAR: begin
            clr_enable = 1;
            oPlot = 1;
            colour = 3'b0;
         end
    
      endcase 
      
   end

   //current_state registers
   always @(posedge iClock) 
   begin: state_FFs
      if (!iResetn)
         current_state <= S_LOAD_X;
      else 
         current_state <= next_state;
   end

endmodule