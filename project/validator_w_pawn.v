module validator_w_pawn (
  input clk,
  input memory_lock,
  input reset,
  // path info
  input [2:0] piece_x, piece_y,
  input [2:0] move_x, move_y,
  // memory access
  input [3:0] validate_square,
  output reg [2:0] validate_x, validate_y,
  output reg queen_valid // result
  );

  wire [2:0] x_dis, y_dis, product_dis;
  assign x_dis = (move_x > piece_x) ? (move_x - piece_x) : (piece_x - move_x);
  assign y_dis = (move_y > piece_y) ? (move_y - piece_y) : (piece_y - move_y);
  assign product_dis = x_dis * y_dis;
  // to be done

endmodule // validator_w_pawn
