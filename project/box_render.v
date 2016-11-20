`ifndef box_render_m
`define box_render_m
// draw a 26 pixel size select box
module box_render (
  input clk,
  input reset,
  input start_render,
  input start_erase,
  input [2:0] box_x, box_y,
  input box_on,

  output [8:0] x,
  output [7:0] y,
  output colour,
  output reg writeEn,
  output reg render_complete,
  output reg erase_complete
  );

  reg [8:0] x_position;
  reg [7:0] y_position;
  assign x = (box_x * 28) + 8 + x_position;
  assign y = (box_y * 28) + 8 + y_position;

  // erase?
  reg erase;

  // identify the colour of square
  wire square_colour, colour_to_use;
  wire [9:0] square_identifier, xy_sum;
  assign xy_sum = box_x + box_y;
  assign square_identifier = xy_sum / 2;
  assign colour_to_use = ~((square_identifier * 2) == xy_sum); // colour_to_use = ! square_colour

  assign colour = (box_on && ~erase) ? ~colour_to_use : colour_to_use;

  // FSM
  reg [2:0] current_state, next_state;
  localparam  S_INIT = 3'd0,
              S_RENDER_PIXEL = 3'd1,
              S_COUNT_X = 3'd2,
              S_COUNT_Y = 3'd3,
              S_COMPLETE = 3'd4;

  always @ ( * ) begin
    case (current_state)
      S_INIT: next_state = (start_render || start_erase) ? S_RENDER_PIXEL : S_INIT;
      S_RENDER_PIXEL: next_state = S_COUNT_X;
      S_COUNT_X: next_state = (x_position == 27) ? S_COUNT_Y : S_RENDER_PIXEL;
      S_COUNT_Y: next_state = (y_position == 27) ? S_COMPLETE : S_RENDER_PIXEL;
      S_COMPLETE: next_state = S_INIT;
      default: next_state = S_INIT;
    endcase
  end

  // render signals
  always @ ( * ) begin
    if(current_state == S_COMPLETE)
      render_complete = 1'b1;
    else
      render_complete = 1'b0;
  end

  // erase signals
  always @ ( * ) begin
    if(y_position == 27 && erase)
      erase_complete = 1'b1;
    else
      erase_complete = 1'b0;
  end

  always @ ( posedge clk ) begin
    if(current_state == S_COMPLETE)
      erase <= 1'b0;
    if(start_erase)
      erase <= 1'b1;
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
      S_COUNT_Y: begin
      if(y_position == 27)
        y_position <= 8'b0;
      else
        y_position <= y_position + 1;
    end
    endcase
  // if(current_state != S_INIT) begin
  //   $display("---------box_render--------");
  //   $display("Current State %d", current_state);
  // end
//    $display("WriteEN:%b", writeEn);
//    $display("x:%d, y:%d", x, y);
//   $display("x_pos:%d y_pos:%d", x_position, y_position);
//    $display("Colour:%b", colour);
  end

  // draw box
  always @ ( * ) begin
    if(x_position == 0 || x_position == 27 || y_position == 0 || y_position == 27) begin
      writeEn = 1'b1;
    end
    else
      writeEn = 1'b0;
  end

  always @(posedge clk) begin
    if(reset)
      current_state <= S_INIT;
    else
      current_state <= next_state;
  end
endmodule // box_render
`endif
