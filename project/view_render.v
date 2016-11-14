module view_render (
  input clk,
  input reset,
  input [3:0] piece_read,
  input [2:0] box_x, box_y, // position of the select box
  input current_player,
  input winning_msg,
  input start_render_board, // from controller
  // lots of input from pic modules

  output reg [8:0] x,
  output reg [7:0] y,
  output reg colour,
  output reg writeEn,
  output reg [2:0] view_x, view_y,
  output reg board_render_complete
  );

  // basically the view render read from the board memory
  // and place the pixels in picture read from pic memory

  // also render the select box

  // each piece is 28*28 pixel size
  // the board is 320*240 pixel size
  // the left up corner of the board is (8, 8)
endmodule // view_render
