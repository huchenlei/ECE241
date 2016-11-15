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
  output [6:0] HEX0, HEX1, HEX2, HEX3, HEX4, HEX5,
  output [9:0] LEDR
  );

  wire winning_msg, current_player, start_render_board, board_render_complete;
  assign LEDR[0] = winning_msg; // 1: win 0: not win
  assign LEDR[1] = current_player; // 0: player1 1: player2
  assign LEDR[2] = start_render_board;
  assign board_render_complete = SW[8];

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

  // display select box
  hex_decoder h0({1'b1, address_control[2:0]}, HEX0);
  hex_decoder h1(4'b0, HEX1);
  hex_decoder h2({1'b0, address_control[5:3]}, HEX2);
  hex_decoder h3(4'b0, HEX3);
  hex_decoder h4(piece_read, HEX4);
  hex_decoder h5(4'b0, HEX5);

  // Controller
  wire [2:0] destination_x, destination_y;
  wire [2:0] origin_x, origin_y;
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
    .piece_to_move(piece_to_move),
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
