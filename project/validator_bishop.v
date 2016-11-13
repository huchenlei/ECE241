module validator_bishop (
  input clk,
  output reg bishop_complete,
  input reset,
  // path info
  input [2:0] piece_x, piece_y,
  input [2:0] move_x, move_y,
  // memory access
  input [3:0] piece_read,
  output reg [5:0] address_validator,
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
	 $display("[Bishop] x_dis:%d y_dis:%d", x_dis, y_dis);
   bishop_complete = 1'b1;
  end

endmodule // validator_bishop
