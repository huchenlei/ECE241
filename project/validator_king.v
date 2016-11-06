module validator_king (
  input [3:0] piece_x, piece_y,
  input [3:0] move_x, move_y,
  output reg king_valid
  );

  wire [3:0] x_dis, y_dis, product_dis;
  assign x_dis = (move_x > piece_x) ? (move_x - piece_x) : (piece_x - move_x);
  assign y_dis = (move_y > piece_y) ? (move_y - piece_y) : (piece_y - move_y);
  assign product_dis = x_dis * y_dis;

  always @ ( * ) begin
    if((product_dis == 4'd0) || (product_dis == 4'd1))
      king_valid = 1'b1;
    else
      king_valid = 1'b0;
  end
endmodule // validator_king
