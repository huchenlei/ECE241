module memory_access (
  input [5:0] address_control, address_validator, address_datapath,
  input [3:0] data_in_datapath,
  input clk,
  input writeEn,
  // control signals
  input control_read, validator_read, datapath_set,

  output reg [3:0] data_out_control, data_out_validator
  );

  wire [5:0] address;
  wire [3:0] piece_out;
  board b(address, data_in_datapath, writeEn, clk, piece_out);

  reg [5:0] address_selected;
  assign address = address_selected;

  // set address
  always @ ( posedge clk ) begin
    if(control_read)
      address_selected <= address_control;
    if(validator_read)
      address_selected <= address_validator;
    if(datapath_set && wirteEn) begin
      address_selected <= address_datapath;
    end
  end

  // set output
  always @ ( posedge clk ) begin
    if(control_read)
      data_out_control <= piece_out;
    if(validator_read)
      data_out_validator <= piece_out;
  end
endmodule // memory_access
