module validator_b_pawn (
  input clk,
  input start_validation,
  output reg b_pawn_complete,
  input reset,
  input [2:0] origin_x, origin_y,
  input [2:0] destination_x, destination_y,
  input [3:0] piece_read,

  output [2:0] validate_x, validate_y,
  output reg b_pawn_valid
  );

  // to be done later

endmodule // validator_b_pawn
