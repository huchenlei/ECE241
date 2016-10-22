`timescale 1ns / 1ns // `timescale time_unit/time_precision
module lab5_3 (KEY, SW, LEDR, CLOCK_50);
  input [1:0] KEY;
  input [2:0] SW;
  input CLOCK_50;
  output LEDR[0];
  reg [11:0] data;
  wire result;
  reg out;
  assign LEDR[0] = out;

  pulse_processor #(26'd25000000, 4'b1000) pp(data, result, CLOCK_50);

  always @ ( * ) begin
    case (SW[2:0])
      3'b000: data = 12'b101110000000;
      3'b001: data = 12'b111010101000;
      3'b010: data = 12'b111010111010;
      3'b011: data = 12'b111010100000;
      3'b100: data = 12'b100000000000;
      3'b101: data = 12'b101011101000;
      3'b110: data = 12'b111011101000;
      3'b111: data = 12'b101010100000;
      default: data = 12'b000000000000;
    endcase
    if(KEY[1] == 1'b0)
      out = result;
    else if(KEY[0] == 1'b0)
      out = 1'b0;
  end
endmodule // lab5_3

module pulse_processor (data, light, clk_50, reset);
  input [11:0] data;
  input clk_50;
  input reset;
  output light;

  reg [25:0] high_f_reg;
  reg [4:0] low_f_reg;
  reg out;
  wire enable_high;
  wire enable_low;
  parameter period = 26'd1;//default full frequency
  parameter max_count = 4'b1111;//default max_count

  assign enable_high = (high_f_reg == period)? 1'b1 : 1'b0;
  assign enable_low = (low_f_reg == max_count)? 1'b1 : 1'b0;
  assign light = out;

  // high frequency counter
  always @ (posedge clk_50) begin
    if(enable_high == 1'b1 | reset == 1'b1)
      high_f_reg <= 0; // reset
    else if(enable_high == 1'b0)
      high_f_reg <= high_f_reg + 1; // count
  end

  // low frequency counter
  always @ (enable_high) begin
    if (enable_low == 1'b1 | reset == 1'b1)
      low_f_reg <= 0;
    else if(enable_low == 1'b0)
      low_f_reg <= low_f_reg + 1;
      out = data[low_f_reg];
  end
endmodule // digi_clock
