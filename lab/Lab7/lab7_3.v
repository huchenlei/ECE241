// Part 2 skeleton
`include "pulse_processor.v"

module lab7_3
	(
		CLOCK_50,						//	On Board 50 MHz
		// Your inputs and outputs here
		SW,
		KEY,
		// The ports below are for the VGA output.  Do not change.
		VGA_CLK,   						//	VGA Clock
		VGA_HS,							//	VGA H_SYNC
		VGA_VS,							//	VGA V_SYNC
		VGA_BLANK_N,						//	VGA BLANK
		VGA_SYNC_N,						//	VGA SYNC
		VGA_R,   						//	VGA Red[9:0]
		VGA_G,	 						//	VGA Green[9:0]
		VGA_B   						//	VGA Blue[9:0]
	);

	input			CLOCK_50;				//	50 MHz
	// Declare your inputs and outputs here
	input [9:0] SW;
	input [3:0] KEY;
	// Do not change the following outputs
	output			VGA_CLK;   				//	VGA Clock
	output			VGA_HS;					//	VGA H_SYNC
	output			VGA_VS;					//	VGA V_SYNC
	output			VGA_BLANK_N;				//	VGA BLANK
	output			VGA_SYNC_N;				//	VGA SYNC
	output	[9:0]	VGA_R;   				//	VGA Red[9:0]
	output	[9:0]	VGA_G;	 				//	VGA Green[9:0]
	output	[9:0]	VGA_B;   				//	VGA Blue[9:0]

	wire resetn, reset_screen;
	assign resetn = KEY[0];

	// Create the colour, x, y and writeEn wires that are inputs to the controller.

	wire [2:0] colour;
	wire [7:0] x;
	wire [6:0] y;
	wire writeEn;

	// Create an Instance of a VGA controller - there can be only one!
	// Define the number of colours as well as the initial background
	// image file (.MIF) for the controller.
	vga_adapter VGA(
			.resetn(reset_screen),
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
		defparam VGA.RESOLUTION = "160x120";
		defparam VGA.MONOCHROME = "FALSE";
		defparam VGA.BITS_PER_COLOUR_CHANNEL = 1;
		defparam VGA.BACKGROUND_IMAGE = "black.mif";

	// Put your code here. Your code should produce signals x,y,colour and writeEn

	// control output
	wire ld_black, ld_x, ld_y, ld_plot;

	wire [7:0] x_coordinate;
	wire [6:0] y_coordinate;

	control c0(
		.clk(CLOCK_50),
		.resetn(resetn),
		.ld_black(ld_black),
		.ld_plot(ld_plot),
		.ld_x(ld_x),
		.ld_y(ld_y),
		.x_coordinate(x_coordinate),
		.y_coordinate(y_coordinate)
		);

	datapath d0(
		.clk(CLOCK_50),
		.resetn(resetn),
		.x_coordinate(x_coordinate),
		.y_coordinate(y_coordinate),
		.color(SW[9:7]),
		.ld_x(ld_x),
		.ld_y(ld_y),
		.x_out(x),
		.y_out(y),
		.color_out(colour)
		);

	assign wirteEn = ld_plot;
	assign reset_screen = resetn | ld_black;

	// for the VGA controller, in addition to any other functionality your design may require.
endmodule // lab7_2

module control (
	input clk,
	input resetn,
	output reg ld_black,
	output reg ld_plot,
	output reg ld_x,
	output reg ld_y
	output reg [7:0] x_coordinate,
	output reg [6:0] y_coordinate);

	// wire 60_delay_clk;
	wire frame_clk;
	reg count_x, count_y;
	reg x_dir, y_dir;

  // 60Hz clock
  // configrable_clock #(26'd833334) p0(clk, resetn, 60_delay_clk);
	// 4Hz clock
	configrable_clock #(26'd12500000) p1(clk, resetn, frame_clk);

	// move
	always @ ( posedge clk ) begin
		if(count_x) begin
			if(x_dir)
				x_coordinate <= x_coordinate + 1;
			else
				x_coordinate <= x_coordinate - 1;
		end
		if(count_y) begin
			if(y_dir)
				y_coordinate <= y_coordinate + 1;
			else
				y_coordinate <= y_coordinate - 1;
		end
		$display("[Moving] Current position:[x: %d, y: %d]", x_coordinate, y_coordinate);
		$display("[Moving] Current direction: [x: %b, y: %b]", x_dir, y_dir);
	end

	// state_table
	reg[3:0] current_state, next_state // may use 4?

	localparam  S_INIT = 4'd0,
							S_PLOT = 4'd1,
							S_REFRESH_WAIT = 4'd2,
							S_ERASE = 4'd3,
							S_MOVE = 4'd4;

	always @ ( * )
		begin: state_table
		case(current_state)
			S_INIT: next_state = S_PLOT;
			S_PLOT: next_state = S_REFRESH_WAIT;
			// wait 15 frames
			S_REFRESH_WAIT: next_state = frame_clk ? S_ERASE : S_REFRESH_WAIT;
			S_ERASE: next_state = S_MOVE;
			S_MOVE: next_state = S_PLOT;
			default: next_state = S_INIT;
		$display("[StateTable] current_state is state[%d]", current_state);
		$display("[StateTable] next_state would be state[%d]", next_state);
	end

	always @ ( * ) begin
		// by default set all signals to 0
		ld_black = 1'b0;
		ld_plot = 1'b0;
		count_x = 1'b0;
		count_y = 1'b0;

		case(current_state)
			S_INIT: begin
				x_coordinate = 8'b0; // left corner
				y_coordinate = 7'b0; // upper corner
				x_dir = 1'b1; // right
				y_dir = 1'b0; // down
			end
			S_PLOT: begin
				ld_plot = 1'b1;
			end
			S_ERASE: begin
				ld_black = 1'b1;
			end
			S_MOVE: begin
				count_x = 1'b1;
				count_y = 1'b1;
				// reaching the boundary
				if((x_coordinate == 8'b11111111) && (x_dir == 1'b1))
					x_dir = 1'b0;
				if((x_coordinate == 8'b00000000) && (x_dir == 1'b0))
					x_dir = 1'b1;
				if((y_coordinate == 7'b1111111) && (y_dir == 1'b1))
					y_dir = 1'b0;
				if((y_coordinate == 7'b0000000) && (y_dir == 1'b0))
					y_dir = 1'b1;
			end
		endcase
		$display("[EnableSignals]-----------");
		$display("count_x is %b", count_x);
		$display("count_y is %b", count_y);
		$display("ld_black is %b", ld_black);
		$display("ld_plot is %b", ld_plot);
		$display("--------------------------");
	end

	//	current_state registers
	always @ ( posedge clk ) begin
		if(!resetn)
			current_state <= S_INIT;
		else
			current_state <= next_state;
		$display("[StateReg] setting current_state as state[%d]", current_state);
	end
endmodule // control

module datapath (
	input clk,
	input resetn,
	input [7:0] x_coordinate,
	input [6:0] y_coordinate,
	input [2:0] color,
	input ld_x, ld_y,

	output reg [7:0] x_out,
	output reg [6:0] y_out,
	output reg [2:0] color_out
	);

	// load data
	always @ ( posedge clk ) begin
		if(!resetn) begin
			$display("[Data Reset] Resetting all regs");
			x_out <= 8'b0;
			y_out <= 7'b0;
			color_out <= 3'b0;
		end
		else begin
			if(ld_x) begin
				$display("[Data Load] Load x as %d", position);
				x_out <= x_coordinate;
			end
			if(ld_y) begin
				$display("[Data Load] Load y as %d", position);
				y_out <= y_coordinate;
			end
			$display("[Color Load] Load color as %b", color_input);
			color_out <= color;
	end
endmodule // datapath
