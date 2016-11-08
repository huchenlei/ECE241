module validator_knight (
  input [2:0] piece_x, piece_y,
  input [2:0] move_x, move_y,
  // the knight will never be blocked by other piece
  // thus does not need memory access
  // input [3:0] validate_square,
  // output reg [2:0] validate_x, validate_y,
  output reg knight_valid
  );

  wire [2:0] x_dis, y_dis, total_dis;
  assign x_dis = (move_x > piece_x) ? (move_x - piece_x) : (piece_x - move_x);
  assign y_dis = (move_y > piece_y) ? (move_y - piece_y) : (piece_y - move_y);
  assign total_dis = x_dis + y_dis;

  always @ ( * ) begin
    if(x_dis == 3'd0 || y_dis == 3'd0) begin
      knight_valid = 1'b0;
    end
    else begin
      if(total_dis == 3'd3)
        knight_valid = 1'b1;
      else
        knight_valid = 1'b0;
    end
    $display("[Knight] x_dis:%d y_dis:%d", x_dis, y_dis);
  end
endmodule // validator_knight
