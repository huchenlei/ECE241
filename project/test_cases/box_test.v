module main (
  input [9:0] SW,
  input [3:0] KEY,
  input CLOCK_50,

  // VGA output
	output			VGA_CLK,   				//	VGA Clock
	output			VGA_HS,					//	VGA H_SYNC
	output			VGA_VS,					//	VGA V_SYNC
	output			VGA_BLANK_N,				//	VGA BLANK
	output			VGA_SYNC_N,				//	VGA SYNC
	output	[9:0]	VGA_R,   				//	VGA Red[9:0]
	output	[9:0]	VGA_G,	 				//	VGA Green[9:0]
	output	[9:0]	VGA_B   				//	VGA Blue[9:0]
  );

  wire reset;
  wire resetn;
  wire color;
  wire [8:0] x;
  wire [7:0] y;
  wire writeEn;
  assign reset = SW[9];
  assign resetn = ~SW[9];
    // View
  // VGA module from lab7
  // Create an Instance of a VGA controller - there can be only one!
	// Define the number of colours as well as the initial background
	// image file (.MIF) for the controller.
	vga_adapter VGA(
    .resetn(resetn),
    .clock(CLOCK_50),
    .colour(colour),
    .x(x),
    .y(y),
    .plot(writeEn),
    /* Signals for the DAC to drive the monitor. */
    .VGA_R(VGA_R),
    .VGA_G(VGA_G),
    .VGA_B(VGA_B),
    .VGA_HS(VGA_HS),
    .VGA_VS(VGA_VS),
    .VGA_BLANK(VGA_BLANK_N),
    .VGA_SYNC(VGA_SYNC_N),
    .VGA_CLK(VGA_CLK));
  defparam VGA.RESOLUTION = "320x240";
  defparam VGA.MONOCHROME = "TRUE";
  defparam VGA.BACKGROUND_IMAGE = "chess_pics/board_240p.mif";

  // knight picture
  wire start_render, render_complete;
  assign LEDR[0] = render_complete;
  assign start_render = ~KEY[0];

  box_render br(.clk(CLOCK_50), .reset(reset), .start_render(start_render),
                .box_x(3'd0), .box_y(3'd0), .box_on(SW[0]), .x(x), .y(y),
                .colour(colour), .writeEn(writeEn), .render_complete(render_complete));
endmodule // main
