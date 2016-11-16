`ifndef box_render_m
`define box_render_m
// draw a 26 pixel size select box
module box_render (
  input clk,
  input reset,
  input start_render,
  input [2:0] box_x, box_y,
  input box_on,

  output [8:0] x,
  output [7:0] y,
  output colour,
  output reg writeEn,
  output reg render_complete
  );

  reg [8:0] x_position;
  reg [7:0] y_position;
  assign x = (box_x * 28) + 7 + x_position;
  assign y = (box_y * 28) + 7 + y_position;

  // identify the colour of square
  wire square_colour;
  wire [9:0] square_identifier, xy_sum;
  assign xy_sum = x + y;
  assign square_identifier = xy_sum / 2;
  assign colour = ((square_identifier * 2) == xy_sum) // colour_to_use = ! square_colour

  // FSM
  reg [2:0] current_state, next_state;
  localparam  S_INIT = 3'd0;
              S_RENDER_PIXEL = 3'd1;
              S_COUNT_X = 3'd2;
              S_COUNT_Y = 3'd3;
              S_COMPLETE = 3'd4;

  always @ ( * ) begin
    case (current_state)
      S_INIT: begin
        if(start_render)
          next_state = box_on ? S_RENDER_PIXEL : S_COMPLETE;
        else
          next_state = S_INIT;
      S_RENDER_PIXEL: next_state = S_COUNT_X;
      S_COUNT_X: next_state = (x_position == 27) ? S_COUNT_Y : S_RENDER_PIXEL;
      S_COUNT_Y: next_state = (y_position == 27) ? S_COMPLETE : S_RENDER_PIXEL;
      S_COMPLETE: next_state = S_INIT;
      default: next_state = S_INIT;
    endcase
  end

  always @ ( * ) begin
    if(current_state == S_COMPLETE)
      render_complete = 1'b1;
    else
      render_complete = 1'b0;
  end

  // counter module
  always @ ( posedge clk ) begin
    case (current_state)
      S_INIT: begin
        x_position <= 9'b0;
        y_position <= 8'b0;
      end
      S_COUNT_X: begin
        if(x_position == 27)
          x_position <= 9'b0;
        else
          x_position <= x_position + 1;
      end
      S_COUNT_Y: y_position <= y_position + 1;
    endcase
  end

  // draw box
  always @ ( * ) begin
    if(x_position == 1 || x_position == 26) begin
      if(y_position == 1 || y_position == 26)
        writeEn = 1'b1;
      else
        writeEn = 1'b0;
    end
    else
      writeEn = 1'b0;
  end
endmodule // box_render
`endif
