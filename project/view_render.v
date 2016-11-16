`include "configrable_clock.v"
module view_render (
  input clk,
  input reset,
  input reset_clock, // clock used for select box blinking
  input [3:0] piece_read,
  input [2:0] box_x, box_y, // position of the select box
  input current_player,
  input winning_msg,

  output reg [8:0] x,
  output reg [7:0] y,
  output reg colour,
  output reg writeEn,
  output reg [2:0] view_x, view_y,
  );

  // controlling select box blinking
  wire flip_signal;
  configrable_clock #(26'd50000000) clock_view(clk, reset_clock, flip_signal);
  reg box_on;
  always @ ( posedge clk ) begin
    if(reset_clock)
      box_on <= 1'b0;
    if(flip_signal)
      box_on <= box_on + 1;
  end

  // knight picture
  wire [9:0] knight_w_address, pawn_w_address;
  wire [1:0] knight_w_data, pawn_w_data;
  knight_w kw(knight_w_address, clk, knight_w_data);
  pawn_w pw(pawn_w_address, clk, pawn_w_data);

  // other picture modules here...

  // background picture
  // 320x240 bigger than 65536(max memory size Quartus could provide)
  // use 2 65535 instead
  wire [16:0] board_address_top, board_data_bottom;
  wire [1:0] board_data_top, board_data_bottom;
  board_rom_top background_top(board_address_top, clk, board_data_top);
  board_rom_bottom background_bottom(board_address_bottom, clk, board_data_bottom);

  reg board_top_render_start, board_bottom_render_start,
      square_render_start, box_render_start;
  reg board_top_render_complete, board_bottom_render_complete,
      square_render_complete, box_render_complete;
  wire x_coordinate, y_coordinate;
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
      S_INIT: next_state = start_render_board ? S_RENDER_BACKGROUND : S_INIT;
      S_RENDER_BACKGROUND_TOP: next_state = S_RENDER_BACKGROUND_TOP_WAIT;
      S_RENDER_BACKGROUND_TOP_WAIT: next_state = board_top_render_complete ? S_RENDER_BACKGROUND_BOTTOM : S_RENDER_BACKGROUND_TOP_WAIT;
      S_RENDER_BACKGROUND_BOTTOM: next_state = S_RENDER_BACKGROUND_BOTTOM_WAIT;
      S_RENDER_BACKGROUND_BOTTOM_WAIT: next_state = board_bottom_render_complete ? S_RENDER_SQUARE : S_RENDER_BACKGROUND_BOTTOM_WAIT;
      S_RENDER_SQUARE: next_state = S_RENDER_SQUARE_WAIT;
      S_RENDER_SQUARE_WAIT: next_state = square_render_complete ? S_COUNT_COL : S_RENDER_SQUARE_WAIT;
      S_COUNT_COL: next_state = (view_x == 3'd7) ? S_COUNT_COL : S_RENDER_SQUARE;
      S_COUNT_ROW: next_state = (view_y == 3'd7) ? S_RENDER_BOX : S_RENDER_SQUARE;
      S_RENDER_BOX: next_state = S_RENDER_BOX_WAIT;
      S_RENDER_BOX_WAIT: next_state = box_render_complete ? S_COMPLETE;
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

    case (current_state)
      S_RENDER_BACKGROUND_TOP: board_top_render_start = 1'b1;
      S_RENDER_BACKGROUND_BOTTOM: board_bottom_render_start = 1'b1;
      S_RENDER_SQUARE: square_render_start = 1'b1;
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
  wire [9:0] y_box;
  wire colour_box;
  wire wren_box;
  // box x is on 8*8; x_box is on 224 * 224
  box_render br(clk, reset, box_render_start, box_x, box_y,
                box_on, x_box, y_box, colour_box, wren_box, box_render_complete);

  // mux all piece rendering outputs
  wire [8:0] x_board_top, x_board_bottom, x_knight_w, x_pawn_w; //etc...
  wire [7:0] y_board_top, y_board_bottom, y_knight_w, y_pawn_w; //etc...
  wire colour_board_top, colour_board_bottom, colour_knight_w, colour_pawn_w;
  wire wren_board_top, wren_board_bottom, wren_w_knight, wren_w_pawn;
  wire knight_w_complete, pawn_w_complete;

  // WIDTH, HEIGHT, WIDTH_B, HEIGHT_B, PIC_LENGTH
  pic_render #(320, 120, 9, 7, 16) pBK_top(clk, reset, board_top_render_start, 9'd0, 8'd0
                                            board_data_top, board_address_top, x_board_top, y_board_top,
                                            colour_board_top, wren_board_top, board_top_render_complete);
  pic_render #(320, 120, 9, 7, 16) pBK_bottom(clk, reset, board_bottom_render_start, 9'd0, 8'd120,
                                              board_data_bottom, board_address_bottom, x_board_bottom, y_board_bottom,
                                              colour_board_bottom, wren_board_bottom, board_bottom_render_complete);

  pic_render pwknight(clk, reset, square_render_start, x_coordinate, y_coordinate,
                      knight_w_data, knight_w_address, x_knight_w, y_knight_w,
                      colour_knight_w, wren_w_knight, knight_w_complete);
  pic_render pwpawn(clk, reset, square_render_start, x_coordinate, y_coordinate,
                    pawn_w_data, pawn_w_address, x_pawn_w, y_pawn_w,
                    colour_pawn_w, wren_w_pawn, pawn_w_complete);
  // and many other pic render modules here
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
        // other pieces here
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
  end
endmodule // view_render
