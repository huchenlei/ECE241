`ifndef control_m
`define control_m
`include "configrable_clock.v"
module control (
  input clk,
  input reset,
  input up, down, left, right,
  input select, deselect,
  input [3:0] piece_read,
  input initialize_complete, // feed back signal from datapath
  input move_complete, // feed back signal from datapath
  input board_render_complete,
  input erase_complete, // feed back from view (erase the box)

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
  output start_render_board,
  output re_render_box_position,
  output reg move_piece, // start update memory in datapath
  output reset_clock, // reset the clock for box blinking
  output reg initialize_board, // start initialze memory in datapath
  output [3:0] current_state_display
  );

  // FSM
  reg winning;
  reg move_valid;
  wire piece_valid;
  reg select_box_can_move;
  reg read_destination;
  reg start_validation;
  wire validate_complete;

  reg [5:0] current_state, next_state;

  localparam  S_INIT = 6'd0,
              S_INIT_WAIT = 6'd1,
              S_UPDATE_MONITOR = 6'd2,
              S_UPDATE_MONITOR_WAIT = 6'd3,
              S_MOVE_BOX_1 = 6'd4,
              S_SELECT_PIECE = 6'd5,
              S_VALIDATE_PIECE = 6'd6,
              S_MOVE_BOX_2 = 6'd7,
              S_SELECT_DESTINATION = 6'd8,
              S_SELECT_DESTINATION_WAIT = 6'd9,
              S_VALIDATE_DESTINATION = 6'd10,
              S_CHECK_WINNING = 6'd11,
              S_UPDATE_MEMORY = 6'd12,
              S_UPDATE_MEMORY_WAIT = 6'd13,
              S_GAME_OVER = 6'd14;


  // validate piece
  // [BUG]: The player could only control his/her own piece
  assign piece_valid = (piece_read == 4'b0) ? 1'b0 : 1'b1;
  assign reset_clock = reset || (current_state == S_INIT);
  assign current_state_display = current_state[3:0];

// state table
always @ ( * ) begin
    case (current_state)
      S_INIT: next_state = S_INIT_WAIT;
      S_INIT_WAIT: next_state = initialize_complete ? S_UPDATE_MONITOR: S_INIT_WAIT;
      S_UPDATE_MONITOR: next_state = S_UPDATE_MONITOR_WAIT;
      S_UPDATE_MONITOR_WAIT: next_state = board_render_complete ? S_MOVE_BOX_1 : S_UPDATE_MONITOR_WAIT;
      S_MOVE_BOX_1: begin
        // if(select && erase_complete)
        if(select)
          next_state = S_SELECT_PIECE;
        else
          next_state = S_MOVE_BOX_1;
      end
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
          // if(select && erase_complete)
          if(select)
            next_state = S_SELECT_DESTINATION;
          else
            next_state = S_MOVE_BOX_2;
        end
        else begin
          // jump back if deselect piece
          if(!select) next_state = S_MOVE_BOX_1;
          else next_state = S_MOVE_BOX_2;
        end
      end
      S_SELECT_DESTINATION: next_state = S_SELECT_DESTINATION_WAIT;
      S_SELECT_DESTINATION_WAIT: next_state = validate_complete ? S_VALIDATE_DESTINATION : S_SELECT_DESTINATION_WAIT;
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
      S_GAME_OVER: next_state = reset ? S_INIT : S_GAME_OVER;
      default: next_state = S_INIT;
    endcase
end

// setting signals

always @ ( * ) begin
  // by default set all signals to 0
  select_box_can_move = 1'b0;
  initialize_board = 1'b0;
  move_piece = 1'b0;
  start_validation = 1'b0;
  start_render_board = 1'b0;
  // default grant memory access to control
  memory_manage = 2'b00;

  case(current_state)
    S_INIT: initialize_board = 1'b1;
    S_INIT_WAIT: memory_manage = 2'b10; // grant memory access to datapath
    S_UPDATE_MONITOR: start_render_board = 1'b1;
    S_UPDATE_MONITOR_WAIT: memory_manage = 2'b11; // grant memory access to view
    S_MOVE_BOX_1: select_box_can_move = 1'b1;
    S_MOVE_BOX_2: select_box_can_move = 1'b1;
    S_SELECT_DESTINATION: start_validation = 1'b1;
    S_SELECT_DESTINATION_WAIT: memory_manage = 2'b01; // grant memory access to validator module
    S_UPDATE_MEMORY: move_piece = 1'b1;
    S_UPDATE_MEMORY_WAIT: memory_manage = 2'b10; // grant datapath to access memory
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
//  $display("[SelectPiece] %d x:%d, y:%d", piece_to_move, origin_x, origin_y);
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
//  $display("[SelectDestination] %d x:%d, y:%d", piece_read, destination_x, destination_y);
end

// check winning
always @ ( posedge clk ) begin
  if(current_state == S_VALIDATE_DESTINATION)
    winning <= (piece_read == 4'd6) || (piece_read == 4'd12);
  if(current_state == S_INIT)
    winning <= 1'b0;
//  $display("[CheckWinning] winning is %b", winning);
end

// validate move
//move_validator mv(clk, reset, start_validation, piece_to_move, origin_x, origin_y,
//                  destination_x, destination_y, piece_read, address_validator,
//                  move_valid, validate_complete);
// mocking move_validator
 reg [2:0] move_counter;
 assign validate_complete = move_counter == 3'b111;
 always @ ( posedge clk ) begin
   if(reset_clock) move_counter <= 3'b0;
   else begin
     if(memory_manage == 2'b1) begin
       $display("[Mocking Validator]");
       move_counter <= move_counter + 1;
     end
   end
   move_valid <= 1'b1;
 end

// setting state
always @ ( posedge clk ) begin
  if(reset)
    current_state <= S_INIT;
  else
    current_state <= next_state;
end

wire frame_clk;
// 1Hz clock for not so fast select-box moving
configrable_clock #(26'd50000000) c0(clk, reset_clock, frame_clk);
// high frequency clk for testing
// configrable_clock #(26'd1) c0(clk, reset_clock, frame_clk);
// select box
assign re_render_box_position = (current_state == S_MOVE_BOX_1 || current_state == S_MOVE_BOX_2) &&
                                (frame_clk && (up || down || right || left));
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

end

  // log block
//   wire write_log;
//   configrable_clock #(26'd1) clog(clk, reset_clock, write_log);
//   always @(posedge clk) begin
// //	if(write_log) begin
// 	   $display("-----------------Control----------------------");
// 		$display("[Controller] Current state is state[%d]", next_state);
// //	end
// 	case(current_state)
//     S_INIT: $display("Init");
//     S_MOVE_BOX_1: begin
//       $display("[SelectBox1] Current position [x:%d][y:%d]", box_x, box_y);
//     end
//     S_MOVE_BOX_2: begin
//       $display("[SelectBox2] Current position [x:%d][y:%d]", box_x, box_y);
//     end
// 	 S_SELECT_PIECE: begin
// 		$display("selecting piece");
// 	 end
//   endcase
//   end
endmodule // control
`endif
