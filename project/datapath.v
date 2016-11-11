module datapath (
  input clk,
  input reset,
  input [2:0] piece_x, piece_y, // mark the selected piece
  input [2:0] move_x, move_y, // destination coordinates
  input [3:0] piece_to_move,
  input initialize_board,
  input move_piece,

  output reg [2:0] datapath_x, datapath_y
  );


endmodule // datapath
