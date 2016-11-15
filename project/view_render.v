module view_render (
  input clk,
  input reset,
  input [3:0] piece_read,
  input [2:0] box_x, box_y, // position of the select box
  input current_player,
  input winning_msg,
  input start_render_board, // from controller

  output reg [8:0] x,
  output reg [7:0] y,
  output reg colour,
  output reg writeEn,
  output reg [2:0] view_x, view_y,
  output reg board_render_complete
  );

  // knight picture
  wire [9:0] knight_w_address, knight_w_data;
  knight_w kw(clk, knight_w_address, knight_w_data);

  // other picture modules here...

  // background picture
  wire [16:0] board_address, board_data;
  board_rom background(clk, board_address, board_data);

  reg board_render_start, square_render_start;
  reg board_render_complete, square_render_complete;
  wire x_coordinate, y_coordinate;
  // convert from 8*8 to 224*224
  // there is 8 pixel bezzle on each edge of the board
  // each square is 28*28 pixel big
  assign x_coordinate = (view_x * 28) + 8;
  assign y_coordinate = (view_y * 28) + 8;

  // FSM (render the board)
  reg [2:0] current_state, next_state;
  localparam  S_INIT = 3'd0,
              S_RENDER_BACKGROUND = 3'd1,
              S_RENDER_BACKGROUND_WAIT = 3'd2,
              S_RENDER_SQUARE = 3'd3,
              S_RENDER_SQUARE_WAIT = 3'd4,
              S_COUNT_COL = 3'd5,
              S_COUNT_ROW = 3'd6,
              S_COMPLETE = 3'd7;

  always @ ( * ) begin
    case (current_state)
      S_INIT: next_state = start_render_board ? S_RENDER_BACKGROUND : S_INIT;
      S_RENDER_BACKGROUND: next_state = S_RENDER_BACKGROUND_WAIT;
      S_RENDER_BACKGROUND_WAIT: next_state = board_render_complete ? S_RENDER_SQUARE : S_RENDER_BACKGROUND_WAIT;
      S_RENDER_SQUARE: next_state = S_RENDER_SQUARE_WAIT;
      S_RENDER_SQUARE_WAIT: next_state = square_render_complete ? S_COUNT_COL : S_RENDER_SQUARE_WAIT;
      S_COUNT_COL: next_state = (view_x == 3'd7) ? S_COUNT_COL : S_RENDER_SQUARE;
      S_COUNT_ROW: next_state = (view_y == 3'd7) ? S_COMPLETE : S_RENDER_SQUARE;
      S_COMPLETE: next_state = S_INIT;
      default: next_state = S_INIT;
    endcase
  end

  // instantanious signals
  always @ ( * ) begin
    // by default set everything to 0
    board_render_start = 1'b0;
    square_render_start = 1'b0;
    writeEn = 1'b0;
    case (current_state)
      S_RENDER_BACKGROUND: board_render_start = 1'b1;
      S_RENDER_SQUARE: square_render_start = 1'b1;
      S_RENDER_BACKGROUND_WAIT: writeEn = 1'b1;
      S_RENDER_SQUARE_WAIT: writeEn = 1'b1;
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

  // mux all piece rendering outputs
  wire [8:0] x_board, x_knight_w; //etc...
  wire [7:0] y_board, y_knight_w; //etc...
  wire colour_board, colour_knight_w;
  wire knight_w_complete;

  // COLOUR_WIDTH, WIDTH, HEIGHT, WIDTH_B, HEIGHT_B, PIC_LENGTH
  pic_render #(1, 320, 240, 9, 8, 17) pBK(clk, reset, board_render_start, 9'd0, 8'd0
                                          board_data, board_address, x_board, y_board,
                                          colour_board, board_render_complete);
  pic_render pwknight(clk, reset, square_render_start, x_coordinate, y_coordinate,
                      knight_w_data, knight_w_address, x_knight_w, y_knight_w,
                      colour_knight_w, knight_w_complete);
  // and many other pic render modules here
  always @ ( * ) begin
    if(current_state == S_RENDER_SQUARE_WAIT) begin
      case (piece_read)
        4'd8: begin // render a white knight
          x = x_knight_w;
          y = y_knight_w;
          colour = colour_knight_w;
          square_render_complete = knight_w_complete;
        end
      endcase
    end
    else if(current_state == S_RENDER_BACKGROUND_WAIT) begin
      x = x_board;
      y = y_board;
      colour = colour_board;
    end
  end

  // render the select box
  // to be done

endmodule // view_render
