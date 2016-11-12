// `include "mux.v"

module main_lab4 (SW, KEY, LEDR);
  input[9:0] SW;
  input[3:0] KEY;
  output[7:0] LEDR;

  rotate_register r0(KEY[1], KEY[2], KEY[3], SW[7:0], KEY[0], SW[9], LEDR[7:0]);
endmodule // main_lab4

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

module muxed_flip_flop (right, left, LL, Ln, data, clk, reset, q);
  input right, left, LL, Ln, data, clk, reset;
  output q;
  wire conn1, conn2;
  mux2to1 mux1(right, left, LL, conn1);
  mux2to1 mux2(conn1, data, Ln, conn2);
  d_flip_flop dff1(conn2, clk, reset, q);
endmodule // muxed_flip_flop

module rotate_register (PLn, RR, ASR, data, clk, reset, q);
  // PLn parallel load data
  // RR rotate right
  // ASR Arithmetch Shift
  input PLn, RR, ASR, clk, reset;
  input[7:0] data;
  output[7:0] q;
  wire [7:0] conn;
  wire ctrled_clk, LR;
  assign ctrled_clk = clk & ~(RR & ASR);
  muxed_flip_flop m0(conn[7], conn[1], LR, PLn, data[0], clk, reset, q[0]);
  muxed_flip_flop m1(conn[0], conn[2], LR, PLn, data[1], clk, reset, q[1]);
  muxed_flip_flop m2(conn[1], conn[3], LR, PLn, data[1], clk, reset, q[2]);
  muxed_flip_flop m3(conn[2], conn[4], LR, PLn, data[1], clk, reset, q[3]);
  muxed_flip_flop m4(conn[3], conn[5], LR, PLn, data[1], clk, reset, q[4]);
  muxed_flip_flop m5(conn[4], conn[6], LR, PLn, data[1], clk, reset, q[5]);
  muxed_flip_flop m6(conn[5], conn[7], LR, PLn, data[1], clk, reset, q[6]);
  muxed_flip_flop m7(conn[6], conn[0], LR, PLn, data[1], ctrled_clk, reset, q[7]);
endmodule // rotate_register(8bit)
