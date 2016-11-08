module move_validator (
  input clk,
  input reset,
  // selected piece info
  input [3:0] selected_piece,
  input [3:0] piece_x, piece_y,
  input [3:0] move_x, move_y,
  // validator select result
  input [3:0] validate_square,
  // validator select
  output reg [3:0] validate_x, validate_y,
  output reg move_valid
  );

  wire  w_pawn_valid, knight_valid, bishop_valid,
        rook_valid, queen_valid, king_valid, b_pawn_valid;
  wire [3:0] knight_x, knight_y; // etc...
  // validator modules
  validator_knight vkight(piece_x, piece_y, move_x, move_y, knight_valid);
  // etc...

  always @ ( * ) begin
    case (selected_piece)
      4'd1: // White Pawn
        move_valid = w_pawn_valid;
      4'd2: // White Knight
        move_valid = knight_valid;
      4'd3: // White Bishop
        move_valid = bishop_valid;
      4'd4: // White Rook
        move_valid = rook_valid;
      4'd5: // White Queen
        move_valid = queen_valid;
      4'd6: // White King
        move_valid = king_valid;
      4'd7: // Black Pawn
        move_valid = b_pawn_valid;
      4'd8: // Black Knight
        move_valid = knight_valid;
      4'd9: // Black Bishop
        move_valid = bishop_valid;
      4'd10: // Black Rook
        move_valid = rook_valid;
      4'd11: // Black Queen
        move_valid = queen_valid;
      4'd12: // Black King
        move_valid = king_valid;
      default:
        move_valid = 1'b0;
    endcase
  end
endmodule // move_validator
