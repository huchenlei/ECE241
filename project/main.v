/*
  piece loop-up table:
  Empty: 0
  Black:  Pawn: 1
          Knight: 2
          Bishop: 3
          Rook: 4
          Queen:5
          King: 6
  White:  Pawn: 7
          Knight: 8
          Bishop: 9
          Rook: 10
          Queen: 11
          King: 12
*/
module main (
  input [9:0] SW,
  input [3:0] KEY,
  input CLOCK_50,

  // VGA output
  output VGA_CLK,
  output VGA_HS,
  // etc...
  );
  wire reset, up, down, left, right, select;

  // memory module
  wire [5:0] address;
  wire [3:0] x_coordinate, y_coordinate;
  wire [3:0] piece_in, piece_out;
  address_encoder a0(x_coordinate, y_coordinate, address);
  board b(address, piece_in, writeEn, CLOCK_50, piece_out);

  // VGA module

  // control module
  control c0(
    .clk(CLOCK_50),
    .reset(SW[9]),
    // vim hjkl style moving
    .up(KEY[1]), .down(KEY[2]), .left(KEY[3]), .right(KEY[0]),
    .select(SW[0]), .deselect(SW[1]),
    .piece_info(piece_out),

    .winning(),
    .piece_x(x_coordinate), .piece_y(y_coordinate),
    .move_x(), .move_y(),
    .box_x(), .box_y()
    );
  // datapath module

endmodule // main
