//winning 
//select animation

//reload the board
//paint the pieces
//flash
//if the piece moves, find other position
module datapath_view (input clk,resetn,
                input ld_board,enable_count28,update_view,select,colour_flash,now_player_white,
                input [2:0] box_in_x,box_in_y//8*8
                input [3:0] pieceFromMem;
                output reg colour,
                output clear_count28,board_complete,piece_complete,
                output [8:0] x_out,
                output [7:0] y_out, 
                output reg [2:0] view_x,view_y);
                
  reg [4:0] count_x,count_y;
  reg [7:0] count_board_y;
  reg [8:0] count_board_x;
  reg colour_board,colour_board_transparent;//transparent:show this when the piece colour is transparent
  reg [1:0] 
  
  //count 28*28
  always@(posedge clk) begin
    if(clear_count28 || !resetn)begin
        count_x <= 5'b0;
        count_y <= 5'b0;
    end
    else if( !clear_count28 && enable_count28 == 1'b1 && count_x < 5'd28 )
        count_x <= count_x + 1'b1;
    else begin
        count_y <= count_y +1'b1;
        count_x <= 5'b0;
    end 
    $display("[count_x] ",count_x );
    $display("[count_y] ",count_y );            
  end
  assign clear_count28 = (count_y==5'd28)?1'b1:1'b0;
  
  //count 320*240 to load board
  always@(posedge clk) begin
    if(board_complete ==1'b1 || ld_board == 1'b0 || !resetn)begin
        count_board_x <= 9'd0;
        count_board_y <= 8'd0;
    end
    else if( ld_board && count_board_x < 9'd320)
        count_board_x <= count_board_x + 1'b1;
    else begin
        count_board_y <= count_board_y +1'b1;
        count_board_x <= 9'b0;
    end 
    $display("[count_x] ",count_board_x );
    $display("[count_y] ",count_board_y );            
  end
  assign board_complete = (count_board_y==8'd241)?1'b1:1'b0;
  
  //instantiate rom blocks for diff pieces
  board bd({count_board_x,count_board_y},clk,colour_board);
  board bd({count_x,count_y},clk,colour_board_transparent);
  bishop_blk bis_b({count_x,count_y},clk,colour_bis_b);
  //......
  always@(posedge clk) begin
    if (enable_count28 ) begin
      case(pieceFromMem)  
          4'b0:
          4'b1: colour = (colour_bis_b[1])? colour_board_transparent:colour_bis_b;
          //.....
      endcase
    end
    else if(select)
      colour = colour_flash;
    else if (ld_board)
      colour = colour_board;
    end
    $display("[color] ",colour );
  end
  //increment view, goes to memory accesss and get figure
  always@(posedge clk) begin
    if(!resetn || piece_complete)begin
        complete <= 1'b0;
        view_x <= 3'b0;
        view_y <= 3'b0;
    end
    else if (update_view==1'b1) begin
        view_x <= view_x + 1'b1;
        if(view_x == 3'd8) begin
          view_y <= view_y + 1'b1;
          view_x <= 3'b0;
        end
    end
    if(view_x == 3'd8 && view_y == 3'd8)
        piece_complete <= 1'b1;
    $display("[view_x] ",view_x );
    $display("[view_y] ",view_y );
  end
  
  always@(posedge clk) begin
    if(ld_board)begin
      x_out = count_board_x;
      y_out = count_board_y;
    else
    else if(select)begin
      if(((count_y == 5'd0 || count_y == 5'd27) &&(count_x < 5'd4 || count_x > 5'd23))
      || ((count_x == 5'd0 || count_x == 5'd27) &&(count_y < 5'd4 || count_y > 5'd23))
      ) begin
        x_out = box_in_x*5'd28+3'd8 + count_x;
        y_out = box_in_y*5'd28+3'd8 + count_y;
      end
    end
    else begin
      x_out = view_x*5'd28 + count_x;
      y_out = view_y*5'd28 + count_y;
    end
    end
endmodule