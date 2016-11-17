`ifndef view_render_m
`define view_render_m

`include "knight_w.v"
`include "pawn_w.v"
`include "king_w.v"
`include "queen_w.v"
`include "rook_w.v"
`include "bishop_w.v"
`include "knight_b.v"
`include "pawn_b.v"
`include "king_b.v"
`include "queen_b.v"
`include "rook_b.v"
`include "bishop_b.v"
`include "board_rom_top.v"
`include "board_rom_bottom.v"

`include "configrable_clock.v"
`include "box_render.v"
`include "pic_render.v"

module view_render (
  input clk,
  input reset,
  input reset_clock, // clock used for select box blinking
  input [3:0] piece_read,
  input [2:0] box_x, box_y, // position of the select box
  input current_player,
  input winning_msg,
  input start_render_board,

  output reg [8:0] x,
  output reg [7:0] y,
  output reg colour,
  output reg writeEn,
  output reg [2:0] view_x, view_y,
  output reg board_render_complete
  );

  // controlling select box blinking
  wire flip_signal;
  configrable_clock #(26'd50000000) clock_view(clk, reset_clock, flip_signal);
  reg box_on;
  always @ ( posedge clk ) begin
    if(reset_clock)
      box_on <= 1'b0;
    if(flip_signal)
      box_on <= box_on + 1'b1;
  end

  // necessary wires
  wire [9:0] knight_w_address, pawn_w_address, king_w_address,
              queen_w_address, rook_w_address, bishop_w_address,
              knight_b_address, pawn_b_address, king_b_address,
              queen_b_address, rook_b_address, bishop_b_address;
  wire [1:0] knight_w_data, pawn_w_data, king_w_data,
              queen_w_data, rook_w_data, bishop_w_data,
              knight_b_data, pawn_b_data, king_b_data,
              queen_b_data, rook_b_data, bishop_b_data;

  // white pieces
  knight_w kw(knight_w_address, clk, knight_w_data);
  pawn_w pw(pawn_w_address, clk, pawn_w_data);
  king_w kingw(king_w_address, clk, king_w_data);
  queen_w qw(queen_w_address, clk, queen_w_data);
  rook_w rw(rook_w_address, clk, rook_w_data);
  bishop_w bw(bishop_w_address, clk, bishop_w_data);
  // black pieces
  knight_b kb(knight_b_address, clk, knight_b_data);
  pawn_b pb(pawn_b_address, clk, pawn_b_data);
  king_b kingb(king_b_address, clk, king_b_data);
  queen_b qb(queen_b_address, clk, queen_b_data);
  rook_b rb(rook_b_address, clk, rook_b_data);
  bishop_b bb(bishop_b_address, clk, bishop_b_data);

  // other picture modules here...

  // background picture
  // 320x240 bigger than 65536(max memory size Quartus could provide)
  // use 2 65535 instead
  wire [15:0] board_address_top, board_address_bottom;
  wire [1:0] board_data_top, board_data_bottom;
  board_rom_top background_top(board_address_top, clk, board_data_top);
  board_rom_bottom background_bottom(board_address_bottom, clk, board_data_bottom);

  reg board_top_render_start, board_bottom_render_start,
      square_render_start, box_render_start;
  wire board_top_render_complete, board_bottom_render_complete,
       box_render_complete;
  wire [8:0] x_coordinate;
  wire [7:0] y_coordinate;
  reg square_render_complete;
  // convert from 8*8 to 224*224
  // there is 8 pixel bezzle on each edge of the board
  // each square is 28*28 pixel big
  assign x_coordinate = (view_x * 28) + 8;
  assign y_coordinate = (view_y * 28) + 8;

  // FSM (render the board)
  reg [3:0] current_state, next_state;
  localparam  S_INIT = 4'd0,
              S_RENDER_BACKGROUND_TOP = 4'd1,
              S_RENDER_BACKGROUND_TOP_WAIT = 4'd2,
              S_RENDER_BACKGROUND_BOTTOM = 4'd3,
              S_RENDER_BACKGROUND_BOTTOM_WAIT = 4'd4,
              S_RENDER_SQUARE = 4'd5,
              S_RENDER_SQUARE_WAIT = 4'd6,
              S_COUNT_COL = 4'd7,
              S_COUNT_ROW = 4'd8,
              S_RENDER_BOX = 4'd9,
              S_RENDER_BOX_WAIT = 4'd10,
              S_COMPLETE = 4'd11;

  always @ ( * ) begin
    case (current_state)
      S_INIT: next_state = start_render_board ? S_RENDER_BACKGROUND_TOP : S_INIT;
      S_RENDER_BACKGROUND_TOP: next_state = S_RENDER_BACKGROUND_TOP_WAIT;
      S_RENDER_BACKGROUND_TOP_WAIT: next_state = board_top_render_complete ? S_RENDER_BACKGROUND_BOTTOM : S_RENDER_BACKGROUND_TOP_WAIT;
      S_RENDER_BACKGROUND_BOTTOM: next_state = S_RENDER_BACKGROUND_BOTTOM_WAIT;
      S_RENDER_BACKGROUND_BOTTOM_WAIT: next_state = board_bottom_render_complete ? S_RENDER_SQUARE : S_RENDER_BACKGROUND_BOTTOM_WAIT;
      S_RENDER_SQUARE: next_state = S_RENDER_SQUARE_WAIT;
      S_RENDER_SQUARE_WAIT: next_state = square_render_complete ? S_COUNT_COL : S_RENDER_SQUARE_WAIT;
      S_COUNT_COL: next_state = (view_x == 3'd7) ? S_COUNT_ROW : S_RENDER_SQUARE;
      S_COUNT_ROW: next_state = (view_y == 3'd7) ? S_RENDER_BOX : S_RENDER_SQUARE;
      S_RENDER_BOX: next_state = S_RENDER_BOX_WAIT;
      S_RENDER_BOX_WAIT: next_state = box_render_complete ? S_COMPLETE : S_RENDER_BOX_WAIT;
      S_COMPLETE: next_state = S_INIT;
      default: next_state = S_INIT;
    endcase
  end

  // instantanious signals
  always @ ( * ) begin
    // by default set everything to 0
    board_top_render_start = 1'b0;
    board_bottom_render_start = 1'b0;
    square_render_start = 1'b0;
    box_render_start = 1'b0;
    board_render_complete = 1'b0;

    case (current_state)
      S_RENDER_BACKGROUND_TOP: board_top_render_start = 1'b1;
      S_RENDER_BACKGROUND_BOTTOM: board_bottom_render_start = 1'b1;
      S_RENDER_SQUARE: square_render_start = 1'b1;
      S_RENDER_BOX: box_render_start = 1'b1;
      S_COMPLETE: board_render_complete = 1'b1;
    endcase
  end

  // counters
  always @ ( posedge clk ) begin
    case (current_state)
      S_INIT: begin
        view_x <= 3'b0;
        view_y <= 3'b0;
      end
      S_COUNT_COL: begin
        view_x <= view_x + 1;
      end
      S_COUNT_ROW: begin
        view_y <= view_y + 1;
      end
    endcase
  end

  always @ ( posedge clk ) begin
    if(reset)
      current_state <= S_INIT;
    else
      current_state <= next_state;
  end

  // render the select box
  wire [8:0] x_box;
  wire [7:0] y_box;
  wire colour_box;
  wire wren_box;
  // box x is on 8*8; x_box is on 224 * 224
  box_render br(clk, reset, box_render_start, box_x, box_y,
                box_on, x_box, y_box, colour_box, wren_box, box_render_complete);

  // mux all piece rendering outputs
  wire [8:0] x_board_top, x_board_bottom, x_knight_w, x_pawn_w, x_king_w,
            x_queen_w, x_rook_w, x_bishop_w, x_knight_b, x_pawn_b, x_king_b,
            x_quuen_b, x_rook_b, x_bishop_b;
  wire [7:0] y_board_top, y_board_bottom, y_knight_w, y_pawn_w, y_king_w,
            y_queen_w, y_rook_w, y_bishop_w, y_knight_b, y_pawn_b, y_king_b,
            y_quuen_b, y_rook_b, y_bishop_b;
  wire colour_board_top, colour_board_bottom, colour_knight_w, colour_pawn_w, colour_king_w,
      colour_queen_w, colour_rook_w, colour_bishop_w, colour_knight_b, colour_pawn_b, colour_king_b,
      colour_quuen_b, colour_rook_b, colour_bishop_b;
  wire wren_board_top, wren_board_bottom, wren_knight_w, wren_pawn_w, wren_king_w,
      wren_queen_w, wren_rook_w, wren_bishop_w, wren_knight_b, wren_pawn_b, wren_king_b,
      wren_quuen_b, wren_rook_b, wren_bishop_b;
  wire knight_w_complete, pawn_w_complete, king_w_complete,
        queen_w_complete, rook_w_complete, bishop_w_complete,
        knight_b_complete, pawn_b_complete, king_b_complete,
        queen_b_complete, rook_b_complete, bishop_b_complete;

  // WIDTH, HEIGHT, WIDTH_B, HEIGHT_B, PIC_LENGTH
  pic_render #(320, 120, 9, 7, 16) pBK_top(clk, reset, board_top_render_start, 9'd0, 8'd0,
                                            board_data_top, board_address_top, x_board_top, y_board_top,
                                            colour_board_top, wren_board_top, board_top_render_complete);
  pic_render #(320, 120, 9, 7, 16) pBK_bottom(clk, reset, board_bottom_render_start, 9'd0, 8'd120,
                                              board_data_bottom, board_address_bottom, x_board_bottom, y_board_bottom,
                                              colour_board_bottom, wren_board_bottom, board_bottom_render_complete);
  // white pieces
  pic_render pwknight(clk, reset, square_render_start, x_coordinate, y_coordinate,
                      knight_w_data, knight_w_address, x_knight_w, y_knight_w,
                      colour_knight_w, wren_w_knight, knight_w_complete);
  pic_render pwpawn(clk, reset, square_render_start, x_coordinate, y_coordinate,
                    pawn_w_data, pawn_w_address, x_pawn_w, y_pawn_w,
                    colour_pawn_w, wren_w_pawn, pawn_w_complete);
  pic_render pwking(clk, reset, square_render_start, x_coordinate, y_coordinate,
                    king_w_data, king_w_address, x_king_w, y_king_w,
                    colour_king_w, wren_w_king, king_w_complete);
  pic_render pwqueen(clk, reset, square_render_start, x_coordinate, y_coordinate,
                    queen_w_data, queen_w_address, x_queen_w, y_queen_w,
                    colour_queen_w, wren_w_queen, queen_w_complete);
  pic_render pwrook(clk, reset, square_render_start, x_coordinate, y_coordinate,
                    rook_w_data, rook_w_address, x_rook_w, y_rook_w,
                    colour_rook_w, wren_w_rook, rook_w_complete);
  pic_render pwbishop(clk, reset, square_render_start, x_coordinate, y_coordinate,
                    bishop_w_data, bishop_w_address, x_bishop_w, y_bishop_w,
                    colour_bishop_w, wren_w_bishop, bishop_w_complete);
  // black pieces
  pic_render pbpawn(clk, reset, square_render_start, x_coordinate, y_coordinate,
                    pawn_b_data, pawn_b_address, x_pawn_b, y_pawn_b,
                    colour_pawn_b, wren_b_pawn, pawn_b_complete);
  pic_render pwknight(clk, reset, square_render_start, x_coordinate, y_coordinate,
                    knight_w_data, knight_w_address, x_knight_w, y_knight_w,
                    colour_knight_w, wren_w_knight, knight_w_complete);
  pic_render pwking(clk, reset, square_render_start, x_coordinate, y_coordinate,
                    king_w_data, king_w_address, x_king_w, y_king_w,
                    colour_king_w, wren_w_king, king_w_complete);
  pic_render pwqueen(clk, reset, square_render_start, x_coordinate, y_coordinate,
                    queen_w_data, queen_w_address, x_queen_w, y_queen_w,
                    colour_queen_w, wren_w_queen, queen_w_complete);
  pic_render pwrook(clk, reset, square_render_start, x_coordinate, y_coordinate,
                    rook_w_data, rook_w_address, x_rook_w, y_rook_w,
                    colour_rook_w, wren_w_rook, rook_w_complete);
  pic_render pwbishop(clk, reset, square_render_start, x_coordinate, y_coordinate,
                    bishop_w_data, bishop_w_address, x_bishop_w, y_bishop_w,
                    colour_bishop_w, wren_w_bishop, bishop_w_complete);

  always @ ( * ) begin
    if(current_state == S_RENDER_SQUARE_WAIT) begin
      case (piece_read)
        4'd8: begin // render a white knight
          writeEn = wren_w_knight;
          x = x_knight_w;
          y = y_knight_w;
          colour = colour_knight_w;
          square_render_complete = knight_w_complete;
        end
        4'd7: begin // render a white pawn
          writeEn = wren_w_pawn;
          x = x_pawn_w;
          y = y_pawn_w;
          colour = colour_pawn_w;
          square_render_complete = pawn_w_complete;
        end
        4'd12: begin // render a white king
          writeEn = wren_w_king;
          x = x_king_w;
          y = y_king_w;
          colour = colour_king_w;
          square_render_complete = king_w_complete;
        end
        4'd11: begin // render a white queen
          writeEn = wren_w_queen;
          x = x_queen_w;
          y = y_queen_w;
          colour = colour_queen_w;
          square_render_complete = queen_w_complete;
        end
        4'd10: begin // render a white rook
          writeEn = wren_w_rook;
          x = x_rook_w;
          y = y_rook_w;
          colour = colour_rook_w;
          square_render_complete = rook_w_complete;
        end
        4'd9: begin // render a white bishop
          writeEn = wren_w_bishop;
          x = x_bishop_w;
          y = y_bishop_w;
          colour = colour_bishop_w;
          square_render_complete = bishop_w_complete;
        end
        4'd1: begin // render a black pawn
          writeEn = wren_b_pawn;
          x = x_pawn_b;
          y = y_pawn_b;
          colour = colour_pawn_b;
          square_render_complete = pawn_b_complete;
        end
        4'd2: begin // render a black knight
          writeEn = wren_b_knight;
          x = x_knight_b;
          y = y_knight_b;
          colour = colour_knight_b;
          square_render_complete = knight_b_complete;
        end
        4'd6: begin // render a black king
          writeEn = wren_b_king;
          x = x_king_b;
          y = y_king_b;
          colour = colour_king_b;
          square_render_complete = king_b_complete;
        end
        4'd5: begin // render a black queen
          writeEn = wren_b_queen;
          x = x_queen_b;
          y = y_queen_b;
          colour = colour_queen_b;
          square_render_complete = queen_b_complete;
        end
        4'd4: begin // render a black rook
          writeEn = wren_b_rook;
          x = x_rook_b;
          y = y_rook_b;
          colour = colour_rook_b;
          square_render_complete = rook_b_complete;
        end
        4'd3: begin // render a black bishop
          writeEn = wren_b_bishop;
          x = x_bishop_b;
          y = y_bishop_b;
          colour = colour_bishop_b;
          square_render_complete = bishop_b_complete;
        end
      default: begin // render nothing
          writeEn = 1'b0;
          x = 9'b0;
          y = 8'b0;
          colour = 1'b0;
          square_render_complete = 1'b1;
      end
      endcase
    end
    else if(current_state == S_RENDER_BACKGROUND_TOP_WAIT) begin
      writeEn = wren_board_top;
      x = x_board_top;
      y = y_board_top;
      colour = colour_board_top;
    end
    else if(current_state == S_RENDER_BACKGROUND_BOTTOM_WAIT) begin
      writeEn = wren_board_bottom;
      x = x_board_bottom;
      y = y_board_bottom;
      colour = colour_board_bottom;
    end
    else if(current_state == S_RENDER_BOX_WAIT) begin
      writeEn = wren_box;
      x = x_box;
      y = y_box;
      colour = colour_box;
    end
   else begin
    writeEn = 1'b0;
    x = 9'b0;
    y = 8'b0;
    colour = 1'b0;
   end
  end

  // log block
//  wire write_log;
//  configrable_clock #(26'd1000) clog(clk, reset_clock, write_log);
//  always @(posedge clk) begin
//  if(write_log) begin
//    $display("---------------view_render--------------");
//    $display("Current state: %d", current_state);
//    $display("x:%d, y:%d", x, y);
//    $display("writeEn:%b", writeEn);
//    $display("Writing colour:%b", colour);
//  end
//  if(board_bottom_render_complete) begin
//    $display("Bottom complete!");
//    $display("current_state", current_state);
//    $display("next_state", next_state);
//  end
//  if(board_top_render_complete)
//    $display("Top complete!");
//  if(current_state >= S_RENDER_SQUARE && current_state != S_RENDER_SQUARE_WAIT && current_state != S_RENDER_BOX_WAIT) begin
//    $display("---------------view_render2--------------");
//    $display("Current state: %d", current_state);
////    $display("")
//  end
//  if(current_state == S_RENDER_SQUARE)
//    $display("[RENDER SQUARE]Reading %d from x:%d, y:%d", piece_read, view_x, view_y);
//  if(current_state == S_RENDER_BOX)
//    $display("PIECES render complete!");
//  if(current_state == S_COMPLETE)
//    $display("Everything DONE!!!!!!!!!!!!!!!!!!!!!");
//  end

endmodule // view_render
`endif
