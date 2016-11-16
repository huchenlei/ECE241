`ifndef pic_render_m
`define pic_render_m
`include "configrable_clock.v"
// `include "vga_adapter/vga_adapter.v"
// only fit 2 bit(with 2 as alpha(transparent))
module pic_render (clk, reset, start_render, base_x, base_y, pic_data, pic_address, x, y,
							colour, writeEn, render_complete);
  // default param for rendering each piece
  parameter WIDTH = 28;
  parameter HEIGHT = 28;
  parameter WIDTH_B = 5;
  parameter HEIGHT_B = 5;
  parameter PIC_LENGTH = 10;

  input clk;
  input reset;
  input start_render;
  input [8:0] base_x;
  input [7:0] base_y;
  input [1:0] pic_data;

  output [8:0] x;
  output [7:0] y;
  output reg colour;
  output reg writeEn;
  output reg render_complete;
  output [PIC_LENGTH - 1 :0] pic_address;

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
      S_COUNT_X: next_state = (x_position == WIDTH - 1) ? S_COUNT_Y : S_RENDER_PIXEL;
      S_COUNT_Y: next_state = (y_position == HEIGHT - 1) ? S_COMPLETE : S_RENDER_PIXEL;
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
      S_COUNT_X: begin
			if(x_position == WIDTH - 1) x_position <= 0;
			else x_position <= x_position + 1;
		end
      S_COUNT_Y: begin
			y_position <= y_position + 1;
		end
    endcase
  end

  // deal with color output
  always @ ( * ) begin
    if(pic_data == 2'd2) begin
      writeEn = 1'b0;
    end
    else begin
      writeEn = 1'b1;
      colour = (pic_data == 2'b01) ? 1'b1 : 1'b0;
    end
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
	$display("---------------------");
	$display("current state is %d", current_state);
	$display("x:%d, y:%d", x, y);
	$display("colour %d", colour);
	$display("pic_data %b", pic_data);
	$display("wirteEn %b", writeEn);
	$display("pic_add %d", pic_address);
  end
endmodule // pic_render
`endif
