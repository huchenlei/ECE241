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

  // on board output
  output [9:0] LEDR,
  // output [6:0] HEX0, HEX1, HEX2, HEX3, HEX4, HEX5,
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

  // mocking controller
  assign memory_manage = {1'b1, SW[9]}; // 11: view; 10: datapath
  assign address_control = 6'd0;
  assign address_validator = 6'd0;
  // memory module
  memory_access ma(
    address_control, address_validator, address_datapath, address_view,
    data_in_datapath,
    CLOCK_50, writeEn,
    memory_manage, piece_read
    );

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
  // mocking controller
  assign origin_x = 3'b0;
  assign origin_y = 3'b0;
  assign destination_x = 3'd1;
  assign destination_y = 3'd1;
  assign piece_to_move = 4'd2;
  assign current_player = 1'b0;
  assign winning_msg = 1'b0;

  assign move_piece = ~KEY[1];
  assign initialize_board = ~KEY[0];
  assign start_render_board = ~KEY[3];

  assign LEDR[0] = move_complete;
  assign LEDR[1] = initialize_complete;
  assign LEDR[2] = board_render_complete;

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

module hex_decoder(hex_digit, segments);
    input [3:0] hex_digit;
    output reg [6:0] segments;

    always @(*)
        case (hex_digit)
            4'h0: segments = 7'b100_0000;
            4'h1: segments = 7'b111_1001;
            4'h2: segments = 7'b010_0100;
            4'h3: segments = 7'b011_0000;
            4'h4: segments = 7'b001_1001;
            4'h5: segments = 7'b001_0010;
            4'h6: segments = 7'b000_0010;
            4'h7: segments = 7'b111_1000;
            4'h8: segments = 7'b000_0000;
            4'h9: segments = 7'b001_1000;
            4'hA: segments = 7'b000_1000;
            4'hB: segments = 7'b000_0011;
            4'hC: segments = 7'b100_0110;
            4'hD: segments = 7'b010_0001;
            4'hE: segments = 7'b000_0110;
            4'hF: segments = 7'b000_1110;
            default: segments = 7'h7f;
        endcase
endmodule
