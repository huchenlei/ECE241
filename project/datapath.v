module datapath (
  input clk,
  input reset,
  input [2:0] piece_x, piece_y, // mark the selected piece
  input [2:0] move_x, move_y, // destination coordinates
  input [3:0] piece_to_move,
  input initialize_board,
  input move_piece,

  output reg [2:0] datapath_x, datapath_y,
  output reg [3:0] data_out,
  output reg initialize_complete
  );

  // FSM1
  // initialize board
  reg [2:0] current_state, next_state;

  localparam  S_SETUP = 3'd0,
              S_INIT_SQUARE = 3'd1,
              S_COUNT_ROW = 3'd2,
              S_COUNT_COL = 3'd3,
              S_COMPLETE = 3'd4;

  always @ ( * ) begin
    case (current_state)
      S_SETUP: next_state = initialize_board ? S_INIT_SQUARE : S_SETUP;
      S_INIT_SQUARE: begin
        next_state = S_COUNT_ROW;
      end
      S_COUNT_ROW: begin
        next_state = (datapath_x == 3'd7) ? S_COUNT_COL : S_INIT_SQUARE;
      end
      S_COUNT_COL: begin
        next_state = (datapath_y == 3'd7) ? S_COMPLETE : S_INIT_SQUARE;
      end
      S_COMPLETE: begin
        next_state = S_SETUP;
      end
      default: next_state = S_SETUP;
    endcase
  end

  // FSM2
  // move piece
  reg [2:0] current_state_m, next_state_m;
  localparam  S_MOVE_WAIT = 3'd0,
              S_SELECT_DESTINATION = 3'd1,
              S_WRITE_DESTINATION = 3'd2,
              S_SELECT_ORIGIN = 3'd3,
              S_ERASE_ORIGIN = 3'd4;

  always @ ( * ) begin
    case (current_state_m)
      S_MOVE_WAIT:
        next_state_m = move_piece ? S_SELECT_DESTINATION : S_MOVE_WAIT;
      S_SELECT_DESTINATION:
        next_state_m = S_WRITE_DESTINATION;
      S_WRITE_DESTINATION:
        next_state_m = S_SELECT_ORIGIN;
      S_SELECT_ORIGIN:
        next_state_m = S_ERASE_ORIGIN;
      S_ERASE_ORIGIN:
        next_state_m = S_MOVE_WAIT;
      default: next_state_m = S_MOVE_WAIT;
    endcase
  end

  always @ ( posedge clk ) begin
    // initiate board
    case (current_state)
      S_SETUP: begin
        datapath_x <= 3'b0;
        datapath_y <= 3'b0;
        initialize_complete <= 1'b0;
      end
      S_INIT_SQUARE: begin
        if(datapath_y == 3'd1) data_out <= 4'd1; // black pawn
        if(datapath_y == 3'd6) data_out <= 4'd7; // white pawn
        if(datapath_y == 3'd0) begin // black
          if(datapath_x == 3'd0 || datapath_x == 3'd7)
            data_out <= 4'd4; // rook
          if(datapath_x == 3'd1 || datapath_x == 3'd6)
            data_out <= 4'd2; // knight
          if(datapath_x == 3'd2 || datapath_x == 3'd5)
            data_out <= 4'd3; // bishop
          if(datapath_x == 3'd3)
            data_out <= 4'd6; // king
          if(datapath_x == 3'd4)
            data_out <= 4'd5; // queen
        end
        if(datapath_y == 3'd7) begin // white
          if(datapath_x == 3'd0 || datapath_x == 3'd7)
            data_out <= 4'd10; // rook
          if(datapath_x == 3'd1 || datapath_x == 3'd6)
            data_out <= 4'd8; // knight
          if(datapath_x == 3'd2 || datapath_x == 3'd5)
            data_out <= 4'd9; // bishop
          if(datapath_x == 3'd3)
            data_out <= 4'd12; // king
          if(datapath_x == 3'd4)
            data_out <= 4'd11; // queen
        end
        if(datapath_y <= 3'd6 || datapath_y >= 3'd1)
          data_out <= 4'd0; // empty
      end
      S_COUNT_ROW: begin
        datapath_x <= datapath_x + 1;
      end
      S_COUNT_COL: begin
        datapath_y <= datapath_y + 1;
      end
      S_COMPLETE: initialize_complete <= 1'b1;
    endcase

    // move piece
    case (current_state_m)
      S_SELECT_DESTINATION: begin
        datapath_x <= move_x;
        datapath_y <= move_y;
      end
      S_WRITE_DESTINATION: begin
        data_out <= piece_to_move;
      end
      S_SELECT_ORIGIN: begin
        datapath_x <= piece_x;
        datapath_y <= piece_y;
      end
      S_ERASE_ORIGIN: begin
        data_out <= 4'b0;
      end
    endcase
  end

  always @ ( posedge clk ) begin
    if(reset)
      current_state <= S_SETUP;
    else
      current_state <= next_state;
  end

  always @ ( posedge clk ) begin
    if(reset)
      current_state_m <= 3'd0;
    else
      current_state_m <= next_state_m;
  end
endmodule // datapath
