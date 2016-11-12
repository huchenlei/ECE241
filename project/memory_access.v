module memory_access (
  input [5:0] address_control, address_validator,
              address_datapath, address_view,
  input [3:0] data_in_datapath,
  input clk,
  input writeEn,
  // control signals
  // 00: control
  // 01: validator
  // 10: datapath
  // 11: view
  input [1:0] control_signal,

  output reg [3:0] data_out_control, data_out_validator,
                    data_out_view
  );

  wire [5:0] address;
  wire [3:0] piece_out;
  board b(address, data_in_datapath, writeEn, clk, piece_out);

  reg [5:0] address_selected;
  assign address = address_selected;

  // set address
  always @ ( * ) begin
    case (control_signal)
      2'd0: address_selected = address_control;
      2'd1: address_selected = address_validator;
      2'd2: address_selected = address_datapath;
      2'd3: address_selected = address_view;
      default: address_selected = address_control;
    endcase
  end

  // set output
  always @ ( * ) begin
    case (control_signal)
      2'd0: data_out_control = piece_out;
      2'd1: data_out_validator = piece_out;
      2'd3: data_out_view = piece_out;
      default: data_out_control = piece_out;
    endcase
  end
endmodule // memory_access
