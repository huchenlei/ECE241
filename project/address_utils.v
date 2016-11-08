`ifndef address_utils_m
`define address_utils_m

module address_encoder (
  input [2:0] pos_x, pos_y,
  // 64 address
  output [5:0] address
  );
  assign address = (pos_x * 8) + pos_y;
endmodule // address_encoder

module address_decoder (
  input [5:0] address,
  output [2:0] pos_x, pos_y
  );
  assign pos_x = address / 8;
  assign pos_y = address % 8;
endmodule // address_decoder

`endif
