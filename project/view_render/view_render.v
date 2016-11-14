 // basically the view render read from the board memory
  // and place the pixels in picture read from pic memory
  // also render the select box
  // each piece is 28*28 pixel size
  // the board is 320*240 pixel size
  // the left up corner of the board is (8, 8)

  //select box
  module view_render(
	input clk,resetn,if_moved,//somewhere from control
	input [2:0] box_x,//
	inout [2:0] box_y,//selected box, flash
	input [3:0] pieceFromMem,
	output color,
	output [8:0] x_out,
	output [7:0] y_out,
	output [2:0] view_x,view_y
	//input current_player,
	//input winning_msg,
	//input can_render,
	//output reg writeEn,
	);
	
	wire clear_count,complete,ld_xy,enable_count,update_viewXY,
		clear_viewXY,ld_colour,select,now_player_white;
	
	control_view c0(resetn, clk, clear_count,complete,if_moved,
					ld_xy,enable_count,update_viewXY,
					clear_viewXY,ld_colour,select,now_player_white);
	
	datapath_view d0(clk,resetn,
				ld_xy,enable_count,update_viewXY,
				clear_viewXY,ld_colour,select,now_player_white,
				box_in_x,box_in_y,//8*8
				pieceFromMem,
				color,
				clear_count, // clear count of 28*28 box
				x_out,y_out, 
				view_x,view_y);
 endmodule
