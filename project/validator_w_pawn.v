module validator_w_pawn (
  input clk,
  input start_validation,
  output reg w_pawn_complete,
  input reset,
  // path info
  input [2:0] piece_x, piece_y,
  input [2:0] move_x, move_y,
  // memory access
  input [3:0] piece_read,
  output [2:0] validate_x, validate_y,
  output reg w_pawn_valid // result
  );

  wire [2:0] x_dis, y_dis, product_dis;
  assign x_dis = (move_x > piece_x) ? (move_x - piece_x) : (piece_x - move_x);
  assign y_dis = (move_y > piece_y) ? (move_y - piece_y) : (piece_y - move_y);
  assign product_dis = x_dis * y_dis;
  // to be done
  always @ ( * ) begin
    w_pawn_valid = 1'b1;
	 w_pawn_complete = 1'b1;
  end
endmodule // validator_w_pawn
