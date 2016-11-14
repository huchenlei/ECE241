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

  output [6:0] HEX0, HEX1, HEX2, HEX3, HEX4, HEX5, HEX6,
  output [9:0] LEDR
  );

  reg [2:0] destination_x, destination_y;
  reg [2:0] origin_x, origin_y;
  wire [3:0] piece_to_move;
  wire initialize_board;
  wire move_piece;
  wire confirm;

  assign initialize_board = ~KEY[0];
  assign move_piece = ~KEY[1];
  assign confirm = ~KEY[3];
  assign piece_to_move = SW[9:6];

  wire reset;
  wire resetn;
  assign reset = ~KEY[2];
  assign resetn = KEY[2];

  // FSM
  reg [2:0] current_state, next_state;

  localparam  S_READ_ORIGIN_WAIT = 3'd0;
              S_READ_ORIGIN = 3'd1;
              S_READ_DESTINATION_WAIT = 3'd2;
              S_READ_DESTINATION = 3'd3;

  always @ ( * ) begin
    case (current_state)
      S_READ_ORIGIN_WAIT: next_state = confirm ? S_READ_ORIGIN : S_READ_ORIGIN_WAIT;
      S_READ_ORIGIN: next_state = S_READ_DESTINATION_WAIT;
      S_READ_DESTINATION_WAIT: next_state = confirm ? S_READ_DESTINATION :S_READ_DESTINATION_WAIT;
      S_READ_DESTINATION: next_state = S_READ_ORIGIN_WAIT;
      default: S_READ_ORIGIN_WAIT;
    endcase
  end

  // read data
  always @ ( posedge CLOCK_50 ) begin
    case (current_state)
      S_READ_ORIGIN: begin
        origin_x <= SW[5:3];
        origin_y <= SW[2:0];
      end
      S_READ_DESTINATION: begin
        destination_x <= SW[5:3];
        destination_y <= SW[2:0];
      end
      default: begin
        origin_x <= 3'b0;
        origin_y <= 3'b0;
        destination_x <= 3'b0;
        destination_y <= 3'b0;
      end
    endcase
  end

  always @ ( posedge CLOCK_50 ) begin
    if(reset)
      current_state <= S_READ_ORIGIN_WAIT;
    else
      current_state <= next_state;
  end
  // Model
  wire [5:0] address_datapath,
  wire [3:0] data_in_datapath;
  wire [3:0] piece_read;

  board b0(address_datapath, data_in_datapath, ~SW[8], CLOCK_50, piece_read);

  // display result
  hex_decoder d0({1'b0, origin_y}, HEX0);
  hex_decoder d1({1'b0, origin_x}, HEX1);
  hex_decoder d2({1'b0, destination_y}, HEX2);
  hex_decoder d3({1'b0, destination_x}, HEX3);
  hex_decoder d4(piece_to_move, HEX5);
  hex_decoder d5(piece_read, HEX6);

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
