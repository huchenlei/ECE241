module validator_knight (
  input clk,
  output reg knight_complete,
  input reset,
  input [2:0] piece_x, piece_y,
  input [2:0] move_x, move_y,
  // memory access
  input [3:0] piece_read,
  output reg [5:0] address_validator,
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
    knight_complete = 1'b1;
  end
endmodule // validator_knight
