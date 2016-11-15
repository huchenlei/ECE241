//the board is 320*240 pixel size
  // the left up corner of the board is (8, 8)
	//each box is 28*28
	//board itself is 224*224 
module control_view(
	input resetn, clk,
  input clear_count28,//clear count 28*28 from datapath
  input board_complete,//complete loading board
  input piece_complete,//complete loading pieces
  input if_moved, // signal from control.v
  output reg ld_board;
	output reg enable_count28,
  output reg update_view,
  output reg select,
  output reg colour_flash,
  output reg now_player_white
    );
	reg [2:0] current_state, next_state;	
  wire frame_clk;
	localparam  S_LOAD_BOARD   = 3'd0,
					S_DRAW          = 3'd1,
					S_UPDATE_VIEW  = 3'd2,
					S_SELECT_FLASH   = 3'd3;
		//load board
		always@(*)
		begin: state_table 
      case (current_state)
        S_LOAD_BOARD: next_state = board_complete? S_UPDATE_XYINI : S_LOAD_BOARD;
        S_DRAW: next_state = clear_count28? S_UPDATE_VIEW_XY : S_DRAW;        
        S_UPDATE_VIEW: next_state = piece_complete? S_SELECT_FLASH : S_DRAW; //move select from control.v
        S_SELECT_FLASH: next_state = if_moved? S_LOAD_XY : S_SELECT_FLASH;
      default:next_state = S_SELECT_FLASH;
			endcase
			$display("--------------current state is ",current_state );
			$display("--------------next state is ",next_state );
		end // state_table
    
		always @(*) 
		begin: enable_signals
			enable_count28 = 1'b0;
			update_view = 1'b0;
      ld_board =1'b0;
      select = 1'b0;
			case(current_state)
        S_LOAD_BOARD: ld_board =1'b1;
				S_DRAW: enable_count28 = 1'b1;
				S_UPDATE_VIEW: update_view = 1'b1;
				S_SELECT_FLASH: begin
          select = 1'b1;
          enable_count28 = 1'b1;
				end
			endcase	
		end	
		
		always@(posedge clk)
		begin: state_FFs
			if(!resetn)
				current_state <= S_LOAD_BOARD;
			else
				current_state <= next_state;
		end 
		
		always@(posedge clk)
		begin: state_FFs
			if(!resetn)
				colour_flash <= 1'b0;
			else if(frame_clk)
				colour_flash <= ~colour_flash;
		end
		
		configrable_clock #(26'd1) c0(clk, resetn, frame_clk);
	
		//current player
		/*always@(posedge clk)
		begin: state_FFs
			if(current_player == 1'b0) //black
				now_player_white = 1'b0;
			else
				now_player_white = 1'b1;
		end*/
 endmodule