`ifndef piece_validator_m
`define piece_validator_m
module piece_validator (
  input current_player,
  input [3:0] piece_read,

  output reg piece_valid
  );
  always @ ( * ) begin
    if(current_player == 1'b0) begin // black
      if(piece_read > 4'd0 && piece_read < 4'd7)
        piece_valid = 1'b1;
      else
        piece_valid = 1'b0;
    end
    else begin // white
      if(piece_read > 4'd6 && piece_read < 4'd13)
        piece_valid = 1'b1;
      else
        piece_valid = 1'b0;
    end
  end
endmodule // piece_validator
`endif
