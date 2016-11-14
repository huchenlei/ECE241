 module validator_rook (
  input clk,
  input start_validation,
  output reg rook_complete,
  input reset,
  // path info
  input [2:0] piece_x, piece_y,
  input [2:0] move_x, move_y,
  // memory access
  input [3:0] piece_read,
  output [5:0] address_validator,
  output reg rook_valid // result
  );

  // memory access signal
  reg validate_path, start_path_check;
  wire path_validated;

  reg [2:0] validate_x, validate_y;
  assign address_validator = {validate_x, validate_y};

  wire [2:0] x_dis, y_dis, product_dis, move_dir_is_x, distance;
  assign x_dis = (move_x > piece_x) ? (move_x - piece_x) : (piece_x - move_x);
  assign y_dis = (move_y > piece_y) ? (move_y - piece_y) : (piece_y - move_y);
  assign product_dis = x_dis * y_dis;
  assign move_dir_is_x = (x_dis == 3'b0) ? 1'b0 : 1'b1;
  assign distance = (x_dis == 3'b0) ? y_dis : x_dis;

  reg [2:0] current_state, next_state;
  localparam  S_CHECK_MOVE = 3'd0,
              S_CHECK_PATH = 3'd1,
              S_OUTPUT_RESULT = 3'd2,
              S_WAIT_FOR_MEMORY = 3'd3;

  // state_table
  // need to garantte that during the validation
  // the module always has the memory access right
  always @ ( * ) begin
    case (current_state)
      S_WAIT_FOR_MEMORY:
        next_state = start_validation ? S_CHECK_MOVE : S_WAIT_FOR_MEMORY;
      S_CHECK_MOVE:
        next_state = validate_path ? S_OUTPUT_RESULT : S_CHECK_PATH;
      S_CHECK_PATH:
        next_state = path_validated ? S_OUTPUT_RESULT : S_CHECK_PATH;
      S_OUTPUT_RESULT:
        next_state = S_WAIT_FOR_MEMORY;
      default: next_state = S_WAIT_FOR_MEMORY;
    endcase
  end

  always @ ( posedge clk ) begin
    if(reset)
      current_state <= S_WAIT_FOR_MEMORY;
    else
      current_state <= next_state;
    $display("-----------------------------------------");
    $display("[RookValidator] Current state is state[%d]", next_state);
  end

  // setting signals
  always @ ( * ) begin
    start_path_check = 1'b0;
    rook_complete = 1'b0;
    case (current_state)
      S_CHECK_PATH: begin
        start_path_check = 1'b1;
      end
      S_OUTPUT_RESULT: begin
        rook_complete = 1'b1;
      end
    endcase
  end

  always @ ( * ) begin
    if((x_dis == 3'd0) && (y_dis == 3'd0)) begin
      validate_path = 1'b0;
    end
    else begin
      if(product_dis == 3'd0) validate_path = 1'b1;
      else validate_path = 1'b0;
    end
  end

  // test path
  // no other piece should appear on the path
  // between origin position and destination
  reg [2:0] path_counter;
  reg impedance_found;
  // loop control
  assign path_validated = (path_counter == (distance - 1));
  always @ ( posedge clk ) begin
    if(start_path_check)
      path_counter <= 3'b0;
    else
      path_counter <= path_counter + 1;
    $display("[path_counter] %d", path_counter);
    $display("[validate_box] x:%d, y:%d there is %d in the square", validate_x, validate_y, piece_read);
  end

  // access memory
  always @ ( * ) begin
    if(move_dir_is_x) begin
      if(move_x > piece_x) validate_x = piece_x + path_counter;
      else validate_x = piece_x - path_counter;
      validate_y = piece_y;
    end
    else begin
      if(move_y > piece_y) validate_y = piece_y + path_counter;
      else validate_y = piece_y - path_counter;
      validate_x = piece_x;
    end
  end

  always @ ( posedge clk ) begin
    if(piece_read == 3'b0)
      impedance_found <= 1'b1;
    if(validate_path)
      impedance_found <= 1'b0;
    $display("[Validate]impedance_found: %b", impedance_found);
  end

  //result loading
  always @ ( posedge clk ) begin
    if(validate_path) begin
      if(impedance_found) rook_valid <= 1'b0;
      else rook_valid <= 1'b1;
    end
    else begin
      rook_valid <= 1'b0;
    end
  end
endmodule // validator_rook
