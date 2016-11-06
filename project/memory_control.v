module memory_control (
  input [5:0] address_control, address_validator, address_datapath,
  input [3:0] data_in_datapath,
  input clk,
  input WriteEn,
  input control_read, validator_read, datapath_set,

  output [3:0] data_out_control, data_out_validator
  );
  wire [5:0] address;
  wire [3:0] piece_in, piece_out;
  board b(address, piece_in, writeEn, CLOCK_50, piece_out);


endmodule // memory_control
