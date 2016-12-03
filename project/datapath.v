`ifndef datapath_m
`define datapath_m
`include "configrable_clock.v"

module datapath (
  input clk,
  input reset,
  input [2:0] origin_x, origin_y, // mark the selected piece
  input [2:0] destination_x, destination_y, // destination coordinates
  input [3:0] piece_to_move,
  input initialize_board,
  input move_piece,

  output reg [2:0] datapath_x, datapath_y,
  output reg [3:0] data_out,
  output reg initialize_complete,
  output reg move_complete,
  output reg writeEn
  );

  // FSM1
  // initialize board
  reg [2:0] current_state, next_state;

  localparam  S_SETUP = 3'd0,
              S_INIT_SQUARE = 3'd1,
              S_INIT_SQUARE_WAIT = 3'd2,
              // should swap ROW and COL here
              // mis definition
              // logically does not matter
              S_COUNT_ROW = 3'd3,
              S_COUNT_COL = 3'd4,
              S_COMPLETE = 3'd5;
  // clock for memory setting delay (initialing)
  wire reset_clock, count_complete;
  assign reset_clock = (current_state == S_INIT_SQUARE);
  configrable_clock #(26'd1) clock0(clk, reset_clock, count_complete);

  always @ ( * ) begin
    case (current_state)
      S_SETUP: next_state = initialize_board ? S_INIT_SQUARE : S_SETUP;
      S_INIT_SQUARE: begin
        next_state = S_INIT_SQUARE_WAIT;
      end
      S_INIT_SQUARE_WAIT: begin
        next_state = count_complete ? S_COUNT_ROW : S_INIT_SQUARE_WAIT;
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
              S_WRITE_DESTINATION = 3'd1,
              S_WRITE_DESTINATION_WAIT = 3'd2,
              S_ERASE_ORIGIN = 3'd3,
              S_ERASE_ORIGIN_WAIT = 3'd4,
              S_MOVE_COMPLETE = 3'd5;

  // clock for memory setting delay (moving piece)
  wire reset_clock_fsm2, count_complete_fsm2;
  assign reset_clock_fsm2 = (current_state_m == S_WRITE_DESTINATION || current_state_m == S_ERASE_ORIGIN);
  configrable_clock #(26'd1) clock1(clk, reset_clock_fsm2, count_complete_fsm2);

  always @ ( * ) begin
    case (current_state_m)
      S_MOVE_WAIT:
        next_state_m = move_piece ? S_WRITE_DESTINATION : S_MOVE_WAIT;
      S_WRITE_DESTINATION:
        next_state_m = S_WRITE_DESTINATION_WAIT;
      S_WRITE_DESTINATION_WAIT:
        next_state_m = count_complete_fsm2 ? S_ERASE_ORIGIN : S_WRITE_DESTINATION_WAIT;
      S_ERASE_ORIGIN:
        next_state_m = S_ERASE_ORIGIN_WAIT;
      S_ERASE_ORIGIN_WAIT:
        next_state_m = count_complete_fsm2 ? S_MOVE_COMPLETE : S_ERASE_ORIGIN_WAIT;
      S_MOVE_COMPLETE:
        next_state_m = S_MOVE_WAIT;
      default: next_state_m = S_MOVE_WAIT;
    endcase
  end

  always @ ( posedge clk ) begin
    writeEn <= 1'b0;
    // initiate board
    case (current_state)
      S_SETUP: begin
        // only if moving fsm is also waiting
  		  if(current_state_m == S_MOVE_WAIT) begin
            datapath_x <= 3'b0;
            datapath_y <= 3'b0;
  		  end
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
          if(datapath_x == 3'd4)
            data_out <= 4'd6; // king
          if(datapath_x == 3'd3)
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
            data_out <= 4'd11; // king
          if(datapath_x == 3'd4)
            data_out <= 4'd12; // queen
        end
        if(datapath_y < 3'd6 && datapath_y > 3'd1)
          data_out <= 4'd0; // empty
//        $display("[FSM1] filling square[%d, %d] with %d", datapath_x, datapath_y, data_out);
      end
		S_INIT_SQUARE_WAIT: writeEn <= 1'b1;
      S_COUNT_ROW: begin
        if(!(datapath_y == 3'd7 && datapath_x == 3'd7))
          datapath_x <= datapath_x + 1;
//        $display("[FSM1] incrementing datapath_x %d", datapath_x);
      end
      S_COUNT_COL: begin
        if(datapath_y != 3'd7) // avoid writing (0,0) the value of (7,7)
          datapath_y <= datapath_y + 1;
//        $display("[FSM1] incrementing datapath_y %d", datapath_y);
      end
      S_COMPLETE: begin
        initialize_complete <= 1'b1;
//        $display("[FSM1] initialize_complete");
      end
    endcase

    // move piece
    case (current_state_m)
      S_MOVE_WAIT: begin
        move_complete <= 1'b0;
      end
      S_WRITE_DESTINATION: begin
        datapath_x <= destination_x;
        datapath_y <= destination_y;
        data_out <= piece_to_move;
        // $display("[FSM2] write destination as %d", piece_to_move);
      end
		S_WRITE_DESTINATION_WAIT: writeEn <= 1'b1;
      S_ERASE_ORIGIN: begin
        datapath_x <= origin_x;
        datapath_y <= origin_y;
        data_out <= 4'b0;
        // $display("[FSM2] erasing origin");
      end
		S_ERASE_ORIGIN_WAIT: writeEn <= 1'b1;
      S_MOVE_COMPLETE:
        move_complete <= 1'b1;
    endcase
  end

  always @ ( posedge clk ) begin
    if(reset)
      current_state <= S_SETUP;
    else
      current_state <= next_state;
//    $display("--------------------------");
//    $display("[FSM1-initialize] Current state is state[%d]", current_state);
  end

  always @ ( posedge clk ) begin
    if(reset)
      current_state_m <= S_MOVE_WAIT;
    else
      current_state_m <= next_state_m;
    // $display("~~~~~~~~~~~~~~~~~~~~~~~~~~");
    // $display("[FSM2-move_piece] Current state is state[%d]", current_state_m);
  end

  always @(posedge clk) begin
//		$display("move complete?:%b", move_complete);
		if(current_state_m == S_WRITE_DESTINATION)
			$display("[datapath] writing destination: %d to %d, %d", piece_to_move, destination_x, destination_y);
		if(current_state_m == S_WRITE_DESTINATION_WAIT)
		  $display("[datapath] confirm writing destination: %d to %d, %d", piece_to_move, datapath_x, datapath_y);
		if(current_state_m == S_ERASE_ORIGIN)
		  $display("[datapath] erasing destination: %d, %d", origin_x, origin_y);

  end
endmodule // datapath
`endif
