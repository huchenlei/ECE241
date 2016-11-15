`ifndef control_m
`define control_m
module control (
  input clk,
  input reset,
  input up, down, left, right,
  input select, deselect,
  input [3:0] piece_read,
  input initialize_complete, // feed back signal from datapath
  input move_complete, // feed back signal from datapath
  input board_render_complete, // feed back signal from view_render

  output reg current_player,
  output reg winning_msg, // winning condition satisfied?
  output reg [2:0] origin_x, origin_y, // left down corner (0,0)
  output reg [2:0] destination_x, destination_y, // position piece is moving to
  output reg [3:0] piece_to_move,
  output reg [2:0] box_x, box_y, // select box position
  // control signals
  // 00: control
  // 01: validator
  // 10: datapath
  // 11: view
  output reg [1:0] memory_manage, // memory control signal
  output [5:0] address_validator,
  output reg start_render_board, // start board render in view_render
  output reg move_piece, // start update memory in datapath
  output reg initialize_board // start initialze memory in datapath
  );

  // FSM
  reg winning;
  reg move_valid;
  wire piece_valid;
  wire clk_reset;
  reg select_box_can_move;
  reg read_destination;
  wire start_validation;
  wire validate_complete;

  reg [5:0] current_state, next_state;

  localparam  S_INIT = 6'd0,
              S_MOVE_BOX_1 = 6'd1,
              S_SELECT_PIECE = 6'd2,
              S_VALIDATE_PIECE = 6'd3,
              S_MOVE_BOX_2 = 6'd4,
              S_SELECT_DESTINATION = 6'd5,
              // S_VALIDATE_DESTINATION_WAIT = 6'd6,
              S_VALIDATE_DESTINATION = 6'd7,
              S_CHECK_WINNING = 6'd8,
              S_UPDATE_MEMORY = 6'd9,
              S_UPDATE_MEMORY_WAIT = 6'd10,
              S_UPDATE_MONITOR = 6'd11,
              S_UPDATE_MONITOR_WAIT = 6'd12,
              S_GAME_OVER = 6'd13;


  // validate piece
  // [BUG]: The player could only control his/her own piece
  assign piece_valid = (piece_read == 4'b0) ? 1'b0 : 1'b1;
  assign clk_reset = reset || (current_state == S_INIT);

// state table
always @ ( * ) begin
    case (current_state)
      S_INIT: next_state = initialize_complete ? S_MOVE_BOX_1 : S_INIT;
      S_MOVE_BOX_1: next_state = select ? S_SELECT_PIECE : S_MOVE_BOX_1;
      S_SELECT_PIECE: next_state = S_VALIDATE_PIECE;
      S_VALIDATE_PIECE: begin
        if(!select) begin // make sure not get into infinite loop
          next_state = piece_valid ? S_MOVE_BOX_2 : S_MOVE_BOX_1;
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
          else next_state = S_MOVE_BOX_2;
        end
      end
      S_SELECT_DESTINATION: next_state = validate_complete ? S_VALIDATE_DESTINATION : S_SELECT_DESTINATION;
      S_VALIDATE_DESTINATION: begin
        if(!select) begin
          next_state = move_valid ? S_CHECK_WINNING : S_MOVE_BOX_2;
        end
        else begin
          next_state = S_VALIDATE_DESTINATION;
        end
      end
      S_CHECK_WINNING: next_state = winning ? S_GAME_OVER : S_UPDATE_MEMORY;
      S_UPDATE_MEMORY: next_state = S_UPDATE_MEMORY_WAIT;
      S_UPDATE_MEMORY_WAIT: next_state = move_complete ? S_UPDATE_MONITOR : S_UPDATE_MEMORY_WAIT;
      S_UPDATE_MONITOR: next_state = S_UPDATE_MONITOR_WAIT;
      S_UPDATE_MONITOR_WAIT: next_state = board_render_complete ? S_MOVE_BOX_1 : S_UPDATE_MONITOR_WAIT;
      S_GAME_OVER: next_state = reset ? S_INIT : S_GAME_OVER;
      default: next_state = S_INIT;
    endcase
end

// setting signals
assign start_validation = (memory_manage == 2'b01);

always @ ( * ) begin
  // by default set all signals to 0
  select_box_can_move = 1'b0;
  initialize_board = 1'b0;
  move_piece = 1'b0;
  start_render_board = 1'b0;
  // default grant memory access to control
  memory_manage = 2'b00;

  case(current_state)
    S_INIT: begin
      initialize_board = 1'b1;
      memory_manage = 2'b10; // grant memory access to datapath
    end
    S_MOVE_BOX_1: begin
      // might need to grant memory access to view
      // memory_manage = 2'b11;
      select_box_can_move = 1'b1;
    end
    S_MOVE_BOX_2: begin
      select_box_can_move = 1'b1;
    end
    S_SELECT_DESTINATION: memory_manage = 2'b01; // grant memory access to validator module
    S_UPDATE_MEMORY: move_piece = 1'b1;
    S_UPDATE_MEMORY_WAIT: memory_manage = 2'b10; // grant datapath to access memory
    S_UPDATE_MONITOR: start_render_board = 1'b1;
    S_UPDATE_MONITOR_WAIT: memory_manage = 2'b11; // grant view to access memory
  endcase
end

// flip player
always @ ( posedge clk ) begin
  case (current_state)
    S_INIT: current_player <= 1'b0;
    S_CHECK_WINNING: current_player <= ~current_player;
    default: current_player <= current_player;
  endcase
end

// select piece
always @ ( posedge clk ) begin
  case (current_state)
    S_SELECT_PIECE: begin
      origin_x <= box_x;
      origin_y <= box_y;
      piece_to_move <= piece_read; // info to datapath
    end
    S_INIT: begin
      origin_x <= 3'b0;
      origin_y <= 3'b0;
    end
    default: begin
      origin_x <= origin_x;
      origin_y <= origin_y;
    end
  endcase
  $display("[SelectPiece] %d x:%d, y:%d", piece_to_move, origin_x, origin_y);
end

// select destination
always @ ( posedge clk ) begin
  case (current_state)
    S_SELECT_DESTINATION: begin
      destination_x <= box_x;
      destination_y <= box_y;
    end
    S_INIT: begin
      destination_x <= 3'b0;
      destination_y <= 3'b0;
    end
    default: begin
      destination_x <= destination_x;
      destination_y <= destination_y;
    end
  endcase
  $display("[SelectDestination] %d x:%d, y:%d", piece_read, destination_x, destination_y);
end

// check winning
always @ ( posedge clk ) begin
  if(current_state == S_VALIDATE_DESTINATION)
    winning <= (piece_read == 4'd6) || (piece_read == 4'd12);
  if(current_state == S_INIT)
    winning <= 1'b0;
  $display("[CheckWinning] winning is %b", winning);
end

// validate move
move_validator mv(clk, reset, start_validation, piece_to_move, origin_x, origin_y,
                  destination_x, destination_y, piece_read, address_validator,
                  move_valid, validate_complete);
// mocking move_validator
// reg [2:0] move_counter;
// assign validate_complete = move_counter == 3'b111;
// always @ ( posedge clk ) begin
//   if(clk_reset) move_counter <= 3'b0;
//   else begin
//     if(memory_manage == 2'b1) begin
//       $display("[Mocking Validator]");
//       move_counter <= move_counter + 1;
//     end
//   end
//   move_valid <= (move_counter == 3'b111);
// end

// setting state
always @ ( posedge clk ) begin
  if(reset)
    current_state <= S_INIT;
  else
    current_state <= next_state;
  $display("---------------------------------------");
  $display("[Controller] Current state is state[%d]", next_state);
  $display("[Controller] Current player is %b", current_player);
  $display("[Memory] memory_manage:%b", memory_manage);
  $display("[Signal] select:%b", select);
  $display("[Signal] deselect:%b", deselect);
  $display("[Signal] piece_valid:%b", piece_valid);
  $display("[Signal] move_valid:%b", move_valid);
  $display("[Signal] validate_complete:%b", validate_complete);
end

wire frame_clk;
// 4Hz clock for not so fast select-box moving
//configrable_clock #(26'd12500000) c0(clk, reset, frame_clk);
// high frequency clk for testing
configrable_clock #(26'd1) c0(clk, clk_reset, frame_clk);
// select box
always @ ( posedge clk ) begin
  if(current_state == S_INIT) begin
    box_x <= 3'b0;
    box_y <= 3'b0;
  end
  if(select_box_can_move && frame_clk) begin
    if(up) box_x <= box_x + 1;
    if(down) box_x <= box_x - 1;
    if(right) box_y <= box_y + 1;
    if(left) box_y <= box_y - 1;
  end
  $display("[SelectBox] Current position [x:%d][y:%d]", box_x, box_y);
end

endmodule // control
`endif
