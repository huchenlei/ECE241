`timescale 1ns / 1ns // `timescale time_unit/time_precision

module lab5_1 (SW, KEY, HEX0, HEX1);
  input [1:0] SW;
  input KEY[0];
  output [6:0] HEX0;
  output [6:0] HEX1;
  wire [7:0] result;
  wire [7:0] conn;
  counter_unit c1(SW[1], KEY[0], SW[0], conn[0], result[0]);
  counter_unit c2(conn[0], KEY[0], SW[0], conn[1], result[1]);
  counter_unit c3(conn[1], KEY[0], SW[0], conn[2], result[2]);
  counter_unit c4(conn[2], KEY[0], SW[0], conn[3], result[3]);
  counter_unit c5(conn[3], KEY[0], SW[0], conn[4], result[4]);
  counter_unit c6(conn[4], KEY[0], SW[0], conn[5], result[5]);
  counter_unit c7(conn[5], KEY[0], SW[0], conn[6], result[6]);
  counter_unit c8(conn[6], KEY[0], SW[0], conn[7], result[7]);

  hex h0(HEX0, result[3:0]);
  hex h1(HEX1, result[4:7]);
endmodule // counter

module counter_unit (enable, clk, reset, q, result);
  input enable, clk, reset;
  output q, result;
  t_flip_flop t(enable, clk, reset, out);
  assign q = result & enable;
endmodule // counter_unit

module t_flip_flop (enable, clk, reset, q);
  input enable, clk, reset;
  output q;
  wire conn;
  assign conn = enable ^ q;
  d_flip_flop d(conn, clk, reset, q);
endmodule // t_flip_flop

module d_flip_flop (data, clk, reset, q);
  input data, clk, reset;
  output q;
  reg q;
  always @ (posedge clk) begin
    if (reset)
      q <= 1'b0;
    else
      q <= data;
  end
endmodule //d_flip_flop
