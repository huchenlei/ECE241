`ifndef configrable_clock_m
`define configrable_clock_m
module configrable_clock (clk_50, resetn, tick);
  input clk_50;
  input resetn;
  output tick;

  reg [25:0] high_f_reg;
  wire enable_high;
  parameter period = 26'd1; //default half frequency

  assign enable_high = (high_f_reg == period)? 1'b1 : 1'b0;

  // high frequency counter
  always @ (posedge clk_50) begin
    if(enable_high == 1'b1 | (!resetn) == 1'b1) begin
      high_f_reg <= 0; // reset
    end
    else if(enable_high == 1'b0)
      high_f_reg <= high_f_reg + 1; // count
  end
  assign tick = enable_high;
endmodule // pulse_processor
`endif
