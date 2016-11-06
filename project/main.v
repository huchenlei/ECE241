module main (
  input [9:0] SW,
  input [3:0] KEY,
  input CLOCK_50,

  // VGA output
  output VGA_CLK,
  output VGA_HS,
  // etc...
  );
  wire reset, up, down, left, right, select;
  assign reset = SW[9];
  // vim hjkl style moving
  assign right = KEY[0];
  assign up = KEY[1];
  assign down = KEY[2];
  assign left = KEY[3];


  // VGA module

  // control module

  // datapath module

endmodule // main
