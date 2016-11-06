`ifndef control_m
`define control_m
module control (
  input clk,
  input reset,
  input up, down, left, right,
  input select, deselect,

  output reg [1:0] winning, // wining condition satisfied? | winning player
  output reg [3:0] piece_x, piece_y, // left down corner (0,0)
  output reg [3:0] move_x, move_y, // position piece is moving to
  output reg [3:0] box_x, box_y
  );

  // FSM
  reg current_player;
  reg piece_valid, move_valid;
  reg winning;
  reg box_can_move;
  reg read_piece;
  reg [5:0] current_state, next_state;

  localparam  S_INIT = 6'd0,
              S_MOVE_BOX_1 = 6'd1,
              S_SELECT_PIECE = 6'd2,
              S_VALIDATE_PIECE = 6'd3,
              S_MOVE_BOX_2 = 6'd4,
              S_SELECT_DESTINATION = 6'd5,
              S_VALIDATE_DESTINATION = 6'd6,
              S_CHECK_WINNING = 6'd7;
              S_GAME_OVER = 6'd8;

// state table
always @ ( * ) begin
    case (current_state)
      S_INIT: next_state = S_INIT;
      S_MOVE_BOX_1: begin
        next_state = select ? S_SELECT_PIECE : S_MOVE_BOX_1;
      end
      S_SELECT_PIECE: begin
        next_state = S_VALIDATE_PIECE;
      end
      S_VALIDATE_PIECE: begin
        if(!select) begin // make sure not get into infinite loop
          next_state = piece_valid ? S_MOVE_BOX_1 : S_MOVE_BOX_2;
        end
        else begin
          next_state = S_VALIDATE_PIECE;
        end
      end
      S_MOVE_BOX_2: begin
        if(!deselect) begin
          next_state = select ? S_SELECT_DESTINATION : S_MOVE_BOX_2;
        end
        else begin
          // jump back if deselect piece
          if(!select) next_state = S_MOVE_BOX_1;
        end
      end
      S_SELECT_DESTINATION: begin
        next_state = S_VALIDATE_DESTINATION;
      end
      S_VALIDATE_DESTINATION: begin
        if(!select) begin
          next_state = move_valid ? S_CHECK_WINNING : S_MOVE_BOX_2;
        end
        else begin
          next_state = S_VALIDATE_DESTINATION;
        end
      end
      S_CHECK_WINNING: begin
        next_state = winning ? S_GAME_OVER : S_MOVE_BOX_1;
      end
      S_GAME_OVER: begin
        next_state = reset ? S_INIT : S_GAME_OVER;
      end
      default: S_INIT;
    endcase
end

// setting signals
always @ ( * ) begin
  // by default set all signals to 0
  box_can_move = 1'b0;
  read_piece = 1'b0;
  
  case(current_state)
    S_MOVE_BOX_1: begin
      box_can_move = 1'b1;
    end
    S_MOVE_BOX_2: begin
      box_can_move = 1'b1;
    end
    S_SELECT_PIECE: begin
      read_piece = 1'b1;
    end
  endcase
end

// setting state
always @ ( posedge clk ) begin
  if(reset)
    current_state <= S_INIT;
  else
    current_state <= next_state;
  $display("[StateTable] Current state is state[%d]", next_state);
end

wire frame_clk;
// 4Hz clock for not so fast select-box moving
//configrable_clock #(26'd12500000) c0(clk, reset, frame_clk);
// high frequency clk for test
configrable_clock #(26'd1) c0(clk, reset, frame_clk);
// select box
always @ ( posedge clk ) begin
  if(current_state == S_INIT) begin
    box_x <= 4'b0;
    box_y <= 4'b0;
  end
  if(box_can_move && frame_clk) begin
    if(up) box_x <= box_x + 1;
    if(down) box_x <= box_x - 1;
    if(right) box_y <= box_y + 1;
    if(left) box_y <= box_y - 1;
  end
  $display("[SelectBox] Current position [x:%d][y:%d]", box_x, box_y);
end



endmodule // control
`endif
