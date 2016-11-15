`ifndef pic_render_m
`define pic_render_m
`include "configrable_clock.v"
// only fit 1 bit and 2 bit(with 2 as alpha(transparent))
module pic_render (
  input clk,
  input reset,
  input start_render,
  input [8:0] base_x,
  input [7:0] base_y,
  // colour width 1 or 2
  input [COLOUR_WIDTH - 1 :0] pic_data,

  output [PIC_LENGTH - 1 :0] pic_address,
  output [8:0] x,
  output [7:0] y,
  output reg colour,
  output reg render_complete
  );
  // default param for rendering each piece
  parameter COLOUR_WIDTH = 2;
  parameter WIDTH = 28;
  parameter HEIGHT = 28;
  parameter WIDTH_B = 6;
  parameter HEIGHT_B = 6;
  parameter PIC_LENGTH = 10;

  reg [WIDTH_B - 1:0] x_position; // relative position
  reg [HEIGHT_B - 1 :0] y_position; // used for iterating through picture
  assign pic_address = (y_position * WIDTH) + x_position;
  assign x = base_x + x_position;
  assign y = base_y + y_position;

  // FSM
  reg [2:0] current_state, next_state;
  localparam  S_INIT = 3'd0,
              S_RENDER_PIXEL = 3'd1,
              S_RENDER_PIXEL_WAIT = 3'd2, // for possible delay to writing to memory
              S_COUNT_X = 3'd3,
              S_COUNT_Y = 3'd4,
              S_COMPLETE = 3'd5;

  // clock from memory setting delay
  wire reset_clock, count_complete;
  assign reset_clock = (current_state == S_RENDER_PIXEL);
  configrable_clock #(26'd1) clockPicRender(clk, reset_clock, count_complete);

  always @ ( * ) begin
    case (current_state)
      S_INIT: next_state = start_render ? S_RENDER_PIXEL : S_INIT;
      S_RENDER_PIXEL: next_state = S_RENDER_PIXEL_WAIT;
      S_RENDER_PIXEL_WAIT: next_state = count_complete ? S_COUNT_X : S_RENDER_PIXEL_WAIT;
      S_COUNT_X: next_state = (x_position == WIDTH) ? S_COUNT_Y : S_RENDER_PIXEL;
      S_COUNT_Y: next_state = (y_position == HEIGHT) ? S_COMPLETE : S_RENDER_PIXEL;
      S_COMPLETE: next_state = S_INIT;
      default: next_state = S_INIT;
    endcase
  end

  always @ ( posedge clk ) begin
    case (current_state)
      S_INIT: begin
        x_position <= 0;
        y_position <= 0;
      end
      S_COUNT_X: x_position <= x_position + 1;
      S_COUNT_Y: y_position <= y_position + 1;
    endcase
  end

  // let complete arrive earlier a clock edge
  always @ ( * ) begin
    if(current_state == S_COMPLETE)
      render_complete = 1'b1;
    else
      render_complete = 1'b0;
  end

  always @ ( posedge clk ) begin
    if(reset)
      current_state <= S_INIT;
    else
      current_state <= next_state;
  end
endmodule // pic_render
`endif
