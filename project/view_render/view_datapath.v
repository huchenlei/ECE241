
//winning 
//select animation
module datapath_view (input clk,resetn,
                input ld_xy,enable_count,update_viewXY,
                    clear_viewXY,ld_colour,select,now_player_white,
                input [2:0] box_in_x,box_in_y//8*8
                input [3:0] pieceFromMem;
                output reg color,
                output clear_count, // clear count of 28*28 box
                output [8:0] x_out,
                output [7:0] y_out, 
                output reg [2:0] view_x,view_y);
                
  reg [4:0] count_x,count_y;
  reg [8:0] x_initial; 
  reg [7:0] y_initial;
  reg select_colour; //if select & flash
          
  
  always@(posedge clk) begin
    if(!resetn) begin
        y_initial <= 8'd8;  
        x_initial <= 9'd8; 
    end
    else begin
        if(ld_xy)begin
            x_initial <= x_initial + 9'd28;
            y_initial <= y_initial + 9'd28;
        end
    end
    $display("[x_initial] ",x_initial );
    $display("[y_initial] ",y_initial );
  end
  
  always@(posedge clk) begin
    if(clear_count && !resetn)begin
        count_x <= 5'b0;
        count_y <= 5'b0;
    end
    else if( enable_count == 1'b1 && clear_count_x < 5'd28)
        count_x <= count_x + 1'b1;
    else begin
        count_y <= count_y +1'b1;
        count_x <= 5'b0;
    end 
    $display("[count_x] ",count_x );
    $display("[count_y] ",count_y );            
  end
  assign clear_count = (count_y==5'd28)?1'b1:1'b0;
  
  assign x_out = x_initial + count_x;
  assign y_out = y_initial + count_y;
  
  //instantiate ram blocks for diff pieces
  bishop_blk bis_b({count_x,count_y},clk,10'b0,1'b0,memout_bis_b);
  //......
  always@(posedge clk) begin
  $display("[select_colour] ",select_colour );
    if (ld_colour==1'b1) begin
      if(select && select_colour)
          colour = 1'b0; //flash on
      if(!select && select_colour)
          colour = 1'b1;//flash off
      else begin
      case(pieceFromMem)  
          4'b0:
          4'b1: colour = memout_bis_b;
          //.....
      endcase
      end
    end
    $display("[color] ",colour );
  end
  //increment view, goes to memory accesss and get figure
  always@(posedge clk) begin
    if(!resetn)
        complete <= 1'b0;
    if (update_viewXY==1'b1) begin
        view_x <= view_x + 1'b1;
        view_y <= view_y + 1'b1;
        
    end
    else if(!resetn || clear_viewXY) begin
        view_x <= 3'b0;
        view_y <= 3'b0;
    end
    
    if(view_x == 3'd8 && view_y == 3'd8)
        complete <= 1'b1;
        
    $display("[view_x] ",view_x );
    $display("[view_y] ",view_y );
  end
  
  //select box
  always@(posedge clk) begin
    select_colour = 1'b0;
    if(view_x = box_in_x && view_y = box_in_y) begin
    //1st row & last row, count 5 each horizontally
        if((count_y == 5'd0 || count_y == 5'd27) &&(count_x < 5'd4 || count_x > 5'd23))
            select_colour <= 1'b1;
    //1st coloum and last column, count 5 vertically        
        if((count_x == 5'd0 || count_x == 5'd27) &&(count_y < 5'd4 || count_y > 5'd23))
            select_colour <= 1'b1;
        
    
    end             
  end
  

endmodule