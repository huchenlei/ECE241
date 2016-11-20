module validator_queen (
  input clk,
  input start_validation,
  output reg queen_complete,
  input reset,
  // path info
  input [2:0] piece_x, piece_y,
  input [2:0] move_x, move_y,
  // memory access
  input [3:0] piece_read,
  output [2:0] validate_x, validate_y,
  output reg queen_valid // result
  );

  wire [2:0] x_dis, y_dis, product_dis;
  assign x_dis = (move_x > piece_x) ? (move_x - piece_x) : (piece_x - move_x);
  assign y_dis = (move_y > piece_y) ? (move_y - piece_y) : (piece_y - move_y);
  assign product_dis = x_dis * y_dis;

  always @ ( * ) begin
    // staying in original position is not allowed
    if((x_dis == 3'd0) && (y_dis == 3'd0)) begin
      queen_valid = 1'b0;
    end
    else begin
      // queen can move either straight or diagonal
      queen_valid = (x_dis == y_dis) || (product_dis == 0);
    end
//    $display("[Queen] x_dis:%d y_dis:%d", x_dis, y_dis);
    queen_complete = 1'b1;
  end
endmodule // validator_queen
