`timescale 1ns / 1ns // `timescale time_unit/time_precision
module lab5_2 (CLOCK_50, HEX0, SW);
  input [1:0] SW;
  input CLOCK_50;
  output [6:0] HEX0;
  wire [3:0] r0;
  wire [3:0] r1;
  wire [3:0] r2;
  wire [3:0] r3;
  digi_clock d0(CLOCK_50, r0);
  digi_clock #(26'd50000000) d1(CLOCK_50, r1);
  digi_clock #(26'd100000000) d2(CLOCK_50, r2);
  digi_clock #(26'd200000000) d3(CLOCK_50, r3);
  reg [3:0] out;
  always @ ( * ) begin
    case (SW[1:0])
      2'b00:
        out = r0;
      2'b01:
        out = r1;
      2'b10:
        out = r2;
      2'b11:
        out = r3;
      default:
        out = 4'b0000;
    endcase
  end
  hex h0(HEX0, out);
endmodule // lab5_2

module digi_clock (clk_50, result);
  input clk_50;
  output [3:0] result;
  reg [25:0] high_f_reg;
  reg [4:0] low_f_reg;
  wire enable_high;
  wire enable_low;
  parameter period = 26'd1;//default full frequency

  assign enable_high = (high_f_reg == period)? 1'b1 : 1'b0;
  assign enable_low = (low_f_reg == 4'b1111)? 1'b1 : 1'b0;

  assign result = low_f_reg;

  // high frequency counter
  always @ (posedge clk_50) begin
    if(enable_high == 1'b1)
      high_f_reg <= 0; // reset
    else if(enable_high == 1'b0)
      high_f_reg <= high_f_reg + 1; // count
  end

  // low frequency counter
  always @ (enable_high) begin
    if (enable_low == 1'b1)
      low_f_reg <= 0;
    else if(enable_low == 1'b0)
      low_f_reg <= low_f_reg + 1;
  end
endmodule // digi_clock
