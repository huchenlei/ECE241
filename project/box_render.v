`ifndef box_render_m
`define box_render_m
// draw a 26 pixel size select box
module box_render_m (
  input clk,
  input reset,
  input [8:0] base_x,
  input [7:0] base_y,
  input [2:0] box_x, box_y,

  output [8:0] x,
  output [7:0] y,
  output reg colour,
  output writeEn,
  );

  // FSM
  reg [2:0] current_state, next_state;
  localparam  S_ERASE_ = param_value;


endmodule // box_render_m

`endif
