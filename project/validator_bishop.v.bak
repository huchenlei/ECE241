module validator_bishop (
  input clk,
  input memory_lock,
  input reset,
  // path info
  input [2:0] piece_x, piece_y,
  input [2:0] move_x, move_y,
  // memory access
  input [3:0] validate_square,
  output reg [2:0] validate_x, validate_y,
  output reg bishop_valid
  );
  wire [2:0] x_dis, y_dis;
  assign x_dis = (move_x > piece_x) ? (move_x - piece_x) : (piece_x - move_x);
  assign y_dis = (move_y > piece_y) ? (move_y - piece_y) : (piece_y - move_y);

  always @ ( * ) begin
    // staying in original position is not allowed
    if((x_dis == 3'd0) && (y_dis == 3'd0)) begin
      bishop_valid = 1'b0;
    end
    else begin
      bishop_valid = (x_dis == y_dis);
    end
  end
  $display("[Bishop] x_dis:%d y_dis:%d", x_dis, y_dis);
endmodule // validator_bishop
