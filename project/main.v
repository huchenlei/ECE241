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
  wire resetn;
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
  wire [3:0] piece_read;
  // memory module
  memory_access ma(
    address_control, address_validator, address_datapath, address_view,
    data_in_datapath,
    CLOCK_50, writeEn,
    memory_manage, piece_read
    );

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

  wire winning_msg, current_player, start_render_board, board_render_complete;

  view_render v0(
    .clk(CLOCK_50),
    .reset(reset),
    .piece_read(piece_read),
    .box_x(address_control[5:3]), .box_y(address_control[2:0]),
    .current_player(current_player),
    .winning_msg(winning_msg),
    .start_render_board(start_render_board),

    .x(x), .y(y), .colour(colour),
    .writeEn(writeEn), .view_x(address_view[5:3]), .view_y(address_view[2:0]),
    .board_render_complete(board_render_complete)
    );

  // Controller
  wire [2:0] origin_x, origin_y;
  wire [3:0] piece_to_move;
  wire [2:0] destination_x, destination_y;
  wire move_piece, move_complete, initialize_board, initialize_complete;
  // control module
  control c0(
    .clk(CLOCK_50),
    .reset(reset),
    // vim hjkl style moving
    .up(~KEY[1]), .down(~KEY[2]), .left(~KEY[3]), .right(~KEY[0]),
    .select(SW[0]), .deselect(SW[1]),
    .piece_read(piece_read),
    .initialize_complete(initialize_complete),
    .board_render_complete(board_render_complete),
    .move_complete(move_complete),

    .current_player(current_player),
    .winning_msg(winning_msg),
    .origin_x(origin_x), .origin_y(origin_y),
    .destination_x(destination_x), .destination_y(destination_y),
    .box_x(address_control[5:3]), .box_y(address_control[2:0]),
    .memory_manage(memory_manage),
    .address_validator(address_validator),
    .move_piece(move_piece),
    .initialize_board(initialize_board),
    .start_render_board(start_render_board)
    );

  // datapath module
  datapath d0(
    .clk(CLOCK_50),
    .reset(reset),
    .origin_x(origin_x), .origin_y(origin_y),
    .destination_x(destination_x), .destination_y(destination_y),
    .piece_to_move(piece_to_move),
    .initialize_board(initialize_board),
    .move_piece(move_piece),

    .datapath_x(address_datapath[5:3]), .datapath_y(address_datapath[2:0]),
    .initialize_complete(initialize_complete),
    .data_out(data_in_datapath),
    .move_complete(move_complete)
    );
endmodule // main
