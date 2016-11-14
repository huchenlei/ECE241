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
module main (
  input [9:0] SW,
  input [3:0] KEY,
  input CLOCK_50,

  // output from controller
  output winning_msg,
  output current_player,
  output can_render,
  );

  wire reset;
  assign reset = SW[9];
  assign resetn = ~SW[9];

  // Model
  wire [5:0] address_control, address_datapath,
             address_validator, address_view;
  wire [3:0] data_in_datapath;
  wire [1:0] memory_manage;
  wire [3:0] piece_read;
  // memory module
  memory_access ma(
    address_control, address_validator, address_datapath, address_view,
    data_in_datapath,
    CLOCK_50, writeEn,
    memory_manage, piece_read
    );

  wire winning_msg, current_player, can_render;

  // Controller
  wire [2:0] destination_x, destination_y;
  wire [2:0] origin_x, origin_y;
  wire move_piece, initialize_board, initialize_complete;
  // control module
  control c0(
    .clk(CLOCK_50),
    .reset(reset),
    // vim hjkl style moving
    .up(~KEY[1]), .down(~KEY[2]), .left(~KEY[3]), .right(~KEY[0]),
    .select(SW[0]), .deselect(SW[1]),
    .piece_read(piece_read),
    .initialize_complete(initialize_complete),

    .current_player(current_player),
    .winning_msg(winning_msg),
    .destination_x(destination_x), .destination_y(destination_y),
    .origin_x(origin_x), .origin_y(origin_y),
    .box_x(address_control[5:3]), .box_y(address_control[2:0]),
    .memory_manage(memory_manage),
    .address_validator(address_validator),
    .move_piece(move_piece),
    .initialize_board(initialize_board),
    .can_render(can_render)
    );

  // datapath module
  datapath d0(
    .clk(CLOCK_50),
    .reset(reset),
    .destination_x(destination_x), .destination_y(destination_y),
    .origin_x(origin_x), .origin_y(origin_y),
    .piece_to_move(piece_to_move),
    .initialize_board(initialize_board),
    .move_piece(move_piece),

    .datapath_x(address_datapath[5:3]), .datapath_y(address_datapath[2:0]),
    .initialize_complete(initialize_complete),
    .data_out(data_in_datapath)
    );
endmodule // main
