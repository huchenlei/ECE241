module validator_king (
  input clk,
  input start_validation,
  output reg king_complete,
  input reset,
  input [2:0] piece_x, piece_y,
  input [2:0] move_x, move_y,
  input [3:0] piece_read,
  output [2:0] validate_x, validate_y,
  output reg king_valid
  );

  wire [2:0] x_dis, y_dis, product_dis;
  assign x_dis = (move_x > piece_x) ? (move_x - piece_x) : (piece_x - move_x);
  assign y_dis = (move_y > piece_y) ? (move_y - piece_y) : (piece_y - move_y);
  assign product_dis = x_dis * y_dis;

  always @ ( * ) begin
    // staying in original position is not allowed
    if((x_dis == 3'd0) && (y_dis == 3'd0)) begin
      king_valid = 1'b0;
    end
    else begin
      if((product_dis == 3'd0) || (product_dis == 3'd1))
        king_valid = 1'b1;
      else
        king_valid = 1'b0;
    end
//    $display("[King] x_dis:%d y_dis:%d", x_dis, y_dis);
    king_complete = 1'b1;
  end
endmodule // validator_king
