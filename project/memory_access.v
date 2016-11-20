
`include "board.v"
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

  output [3:0] piece_read
  );

  wire [5:0] address;
  board b(address, clk, data_in_datapath, writeEn, piece_read);

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

  always @( posedge clk) begin
    if(control_signal == 2'd2 && writeEn == 1'b1)
	   $display("[memory manage]writing %d to %d, %d", data_in_datapath, address_datapath[5:3], address_datapath[2:0]);
//	$display("-----MemoryAccess------");
//	$display("control signal: %b", control_signal);
//	$display("writeEn: %b", writeEn);
//	$display("Piece_Read/Write: %d", piece_read);
  end
endmodule // memory_access
