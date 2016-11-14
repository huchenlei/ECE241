/*
  piece lookup table:
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
`include "board.v"
`include "datapath.v"

module main (
  input [9:0] SW,
  input [3:0] KEY,
  input CLOCK_50,
  // mock controller
  input [2:0] destination_x, destination_y,
  input [2:0] origin_x, origin_y,
  input [3:0] piece_to_move,
  input initialize_board,
  input move_piece,

  output initialize_complete
  );

  wire reset;
  wire resetn;
  assign reset = SW[9];
  assign resetn = ~SW[9];

  // Model
  wire [5:0] address_datapath,
  wire [3:0] data_in_datapath;
  wire [3:0] piece_read;

  // writeEn SW[8]
  board b0(address_datapath, data_in_datapath, SW[8], CLOCK_50, piece_read);

  // datapath module
  datapath d0(
    .clk(CLOCK_50),
    .reset(reset),
    .piece_x(piece_x), .piece_y(piece_y),
    .move_x(move_x), .move_y(move_y),
    .piece_to_move(piece_to_move),
    .initialize_board(initialize_board),
    .move_piece(move_piece),

    .datapath_x(address_datapath[5:3]), .datapath_y(address_datapath[2:0]),
    .initialize_complete(LEDR[0]),
    .data_out(data_in_datapath)
    );
endmodule // main
