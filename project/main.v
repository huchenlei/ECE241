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

  // VGA output
  output VGA_CLK,
  output VGA_HS,
  // etc...
  );

  wire [5:0] address_control, address_datapath, address_validator;
  wire [3:0] data_in_datapath;
  wire [1:0] memory_manage;
  wire writeEn;
  wire [3:0] data_out_control, data_out_validator;
  // memory module
  memory_access ma(
    address_control, address_validator, address_datapath,
    data_in_datapath,
    CLOCK_50, writeEn,
    memory_manage,
    data_out_control, data_out_validator
    );

  wire [3:0] box_x, box_y;
  wire [3:0] validate_x, validate_y;
  address_encoder ae0(box_x, box_y, address_control);
  address_encoder ae1(validate_x, validate_y, address_validator);
  // VGA module


  // control module
  control c0(
    .clk(CLOCK_50),
    .reset(SW[9]),
    // vim hjkl style moving
    .up(KEY[1]), .down(KEY[2]), .left(KEY[3]), .right(KEY[0]),
    .select(SW[0]), .deselect(SW[1]),
    .selected_piece(data_out_control),
    .validate_square(data_out_validator),

    .winning(),
    .piece_x(), .piece_y(),
    .move_x(), .move_y(),
    .box_x(box_x), .box_y(box_y),
    .memory_manage(memory_manage),
    .validate_x(validate_x), .validate_y(validate_y)
    );
  // datapath module

endmodule // main
