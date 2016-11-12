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
	output			VGA_CLK,   				//	VGA Clock
	output			VGA_HS,					//	VGA H_SYNC
	output			VGA_VS,					//	VGA V_SYNC
	output			VGA_BLANK_N,				//	VGA BLANK
	output			VGA_SYNC_N,				//	VGA SYNC
	output	[9:0]	VGA_R,   				//	VGA Red[9:0]
	output	[9:0]	VGA_G,	 				//	VGA Green[9:0]
	output	[9:0]	VGA_B   				//	VGA Blue[9:0]
  );

  wire reset;
  wire color;
  wire [8:0] x;
  wire [7:0] y;
  wire writeEn;
  assign reset = SW[9];
  assign resetn = ~SW[9];

  // Model
  wire [5:0] address_control, address_datapath,
             address_validator, address_view;
  wire [3:0] data_in_datapath;
  wire [1:0] memory_manage;
  wire [3:0] data_out_control, data_out_validator, data_out_view;
  // memory module
  memory_access ma(
    address_control, address_validator, address_datapath, address_view,
    data_in_datapath,
    CLOCK_50, writeEn,
    memory_manage,
    data_out_control, data_out_validator, data_out_view
    );

  wire [2:0] box_x, box_y;
  wire [2:0] validate_x, validate_y;
  wire [2:0] datapath_x, datapath_y;
  wire [2:0] view_x, view_y;
  address_encoder ae0(box_x, box_y, address_control);
  address_encoder ae1(validate_x, validate_y, address_validator);
  address_encoder ae2(datapath_x, datapath_y, address_datapath);
  address_encoder ae3(view_x, view_y, address_view);

  // Initialize picture holding memory modules here...


  // View
  // VGA module from lab7
  // Create an Instance of a VGA controller - there can be only one!
	// Define the number of colours as well as the initial background
	// image file (.MIF) for the controller.
	vga_adapter VGA(
    .resetn(resetn),
    .clock(CLOCK_50),
    .colour(colour),
    .x(x),
    .y(y),
    .plot(writeEn),
    /* Signals for the DAC to drive the monitor. */
    .VGA_R(VGA_R),
    .VGA_G(VGA_G),
    .VGA_B(VGA_B),
    .VGA_HS(VGA_HS),
    .VGA_VS(VGA_VS),
    .VGA_BLANK(VGA_BLANK_N),
    .VGA_SYNC(VGA_SYNC_N),
    .VGA_CLK(VGA_CLK));
  defparam VGA.RESOLUTION = "320x240";
  defparam VGA.MONOCHROME = "TRUE";
  defparam VGA.BACKGROUND_IMAGE = "chess_pics/board_240p.mif";

  wire winning_msg, current_player, can_render;

  view_render v0(
    .data_out_view(data_out_view),
    .box_x(box_x), .box_y(box_y),
    .current_player(current_player),
    .winning_msg(winning_msg),
    .can_render(can_render),

    .x(x), .y(y), .colour(colour),
    .writeEn(writeEn), .view_x(view_x), .view_y(view_y)
    );

  // Controller
  wire [2:0] piece_x, piece_y;
  wire [3:0] piece_to_move;
  wire [2:0] move_x, move_y;
  wire move_piece, initialize_board, initialize_complete;
  // control module
  control c0(
    .clk(CLOCK_50),
    .reset(reset),
    // vim hjkl style moving
    .up(~KEY[1]), .down(~KEY[2]), .left(~KEY[3]), .right(~KEY[0]),
    .select(SW[0]), .deselect(SW[1]),
    .selected_piece(data_out_control),
    .validate_square(data_out_validator),
    .initialize_complete(initialize_complete),

    .current_player(current_player),
    .winning_msg(winning_msg),
    .piece_x(piece_x), .piece_y(piece_y),
    .move_x(move_x), .move_y(move_y),
    .box_x(box_x), .box_y(box_y),
    .memory_manage(memory_manage),
    .validate_x(validate_x), .validate_y(validate_y),
    .move_piece(move_piece),
    .initialize_board(initialize_board),
    .can_render(can_render)
    );

  // datapath module
  datapath d0(
    .clk(CLOCK_50),
    .reset(reset),
    .piece_x(piece_x), .piece_y(piece_y),
    .move_x(move_x), .move_y(move_y),
    .piece_to_move(piece_to_move),
    .initialize_board(initialize_board),
    .move_piece(move_piece),

    .datapath_x(datapath_x), .datapath_y(datapath_y),
    .initialize_complete(initialize_complete),
    .data_out(data_in_datapath)
    );
endmodule // main
