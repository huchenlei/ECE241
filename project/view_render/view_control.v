//the board is 320*240 pixel size
  // the left up corner of the board is (8, 8)
	//each box is 28*28
	//board itself is 224*224 
module control_view(
	input resetn, clk, clear_count,complete,if_moved,
	output reg ld_xy,enable_count,update_viewXY,
	           clear_viewXY,ld_colour,select,now_player_white
    );
   wire clear_delay;
	reg [29:0] delay_counter;
	reg [2:0] current_state, next_state,currentStat_select,nextStat_select;		
		localparam  S_LOAD_XY        = 3'd0,
					S_DRAW_XY          = 3'd1,
					S_DRAW_COLOUR      = 3'd2,
					S_UPDATE_VIEW_XY    = 3'd3,
					S_WAIT_MOVE    =  3'd4,
					S_SELECT_ON   = 1'd0,
					S_SELECT_OFF  = 1'd1;
		//load board
		always@(*)
		begin: state_table 
				
				case (current_state)
					S_LOAD_XY: next_state = S_DRAW_XY;
					S_DRAW_XY: next_state =  S_DRAW_COLOUR;
					S_DRAW_COLOUR: next_state = clear_count? S_UPDATE_VIEW_XY : S_DRAW_XY;
					
					S_UPDATE_VIEW_XY: next_state = complete? S_WAIT_MOVE : S_LOAD_XY; //move select from control.v
					S_WAIT_MOVE: next_state = moved? S_LOAD_XY : S_WAIT_MOVE;
					
				default:     next_state = S_REFRESH;
			endcase
		end // state_table
		
		
		always @(*) 
		begin: enable_signals
			
			ld_xy = 1'b0;
			enable_count = 1'b0;
			update_viewXY = 1'b0;
			clear_viewXY = 1'b0;
			ld_colour=1'b0;
			case(current_state)
				S_LOAD_XY: ld_xy = 1'b1;
				S_DRAW_XY: enable_count = 1'b1;
				S_DRAW_COLOUR: begin
					enable_count = 1'b0;
					ld_colour=1'b1;
				end
				S_UPDATE_VIEW_XY: update_viewXY = 1'b1;
				S_WAIT_MOVE :¡¡clear_viewXY = 1'b1;
				
			endcase	
		end	
		
		always@(posedge clk)
		begin: state_FFs
			if(!resetn)
				current_state <= S_WAIT_MOVE;
			else
				current_state <= next_state;
		end 
		//separate state table for select flash
		always@(*)
		begin
			case (currentStat_select)
				S_SELECT_ON:begin
					nextStat_select = S_SELECT_OFF;
					select = 1'b1;
				end
				begin
					S_SELECT_OFF:nextStat_select = S_SELECT_ON;
					select = 1'b0;
				end
			endcase
		end
		always@(posedge clk)
		begin: state_FFs
			if(!resetn)
				currentStat_select <= S_SELECT_ON;
			else if(clear_delay)
				currentStat_select <= nextStat_select;
			else
				currentStat_select <= S_SELECT_ON;
		end 
		
		always @(posedge clk)
		begin
			if(clear_delay ==1'b1 || resetn == 1'b0 )
				delay_counter <= 30'd0;
			else if(enable_delay == 1'b1)
				delay_counter <= delay_counter + 1'b1;
				
		$display("clear_delay is ",clear_delay );
		$display("delay_counter is ",delay_counter );
		end
		assign clear_delay = (delay_counter==30'd1000000)? 1'b1 : 1'b0;
		
		//current player
		always@(posedge clk)
		begin: state_FFs
			if(current_player == 1'b0) //black
				now_player_white = 1'b0;
			else
				now_player_white = 1'b1;
		end 
		
		
 endmodule
  