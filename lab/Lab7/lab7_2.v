// Part 2 skeleton

module lab7_2
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
	// control input
	wire go, to_black, plot;
	assign go = ~KEY[3];
	assign to_black = ~KEY[2];
	assign plot = ~KEY[1];

	// control output
	wire ld_black, ld_x, ld_y, ld_plot;

	control c0(
		.clk(CLOCK_50),
		.to_black(to_black),
		.plot(plot),
		.resetn(resetn),
		.go(go),
		.ld_black(ld_black),
		.ld_plot(ld_plot),
		.ld_x(ld_x),
		.ld_y(ld_y)
		);

	datapath d0(
		.clk(CLOCK_50),
		.resetn(resetn),
		.pos(SW[6:0]),
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
	input to_black, plot, resetn, go,
	output reg ld_black,
	output reg ld_plot,
	output reg ld_x,
	output reg ld_y);

	// state_table
	reg[3:0] current_state, next_state // may use 4?

	localparam  S_LOAD_X = 4'd0,
							S_LOAD_X_WAIT = 4'd1,
							S_LOAD_Y = 4'd2,
							S_LOAD_Y_WAIT = 4'd3,
							S_PLOT = 4'd4;
							S_BLACK = 4'd5;

	always @ ( * ) begin
		begin: state_table
		case(current_state)
			S_LOAD_X: next_state = go ? S_LOAD_X_WAIT : S_LOAD_X;
			S_LOAD_X_WAIT: next_state = go ? S_LOAD_X_WAIT : S_LOAD_Y;
			S_LOAD_Y: next_state = go ? S_LOAD_Y_WAIT : S_LOAD_Y;
			S_LOAD_Y_WAIT: next_state = plot ? S_LOAD_Y_WAIT : S_PLOT;
			S_PLOT: next_state = S_LOAD_X;
			S_BLACK: next_state = S_LOAD_X;
			default: next_state = S_LOAD_X;
		$display("[StateTable] current_state is state[%d]", current_state);
		$display("[StateTable] next_state would be state[%d]", next_state);
	end

	always @ ( * ) begin
		// by default set all signals to 0
		ld_x = 1'b0;
		ld_y = 1'b0;
		ld_black = 1'b0;
		ld_plot = 1'b0;
		case(current_state)
			S_LOAD_X_WAIT: ld_x = 1'b1;
			S_LOAD_Y_WAIT: ld_y = 1'b1;
			S_PLOT: ld_plot = 1'b1;
			S_BLACK: ld_black = 1'b1;
		endcase
		$display("[EnableSignals]-----------");
		$display("ld_x is %b", ld_x);
		$display("ld_y is %b", ld_y);
		$display("ld_black is %b", ld_black);
		$display("ld_plot is %b", ld_plot);
		$display("--------------------------");
	end

	//	current_state registers
	always @ ( posedge clk ) begin
		if(!resetn) current_state <= S_LOAD_X;
		if(to_black)
			current_state <= S_BLACK;
		else
			current_state <= next_state;
		end
		$display("[StateReg] setting current_state as state[%d]", current_state);
	end
endmodule // control

module datapath (
	input clk,
	input resetn,
	input [6:0] pos,
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
				x_out <= {1'b0, pos};
			end
			if(ld_y) begin
				$display("[Data Load] Load y as %d", position);
				y_out <= pos;
			end
			$display("[Color Load] Load color as %b", color_input);
			color_out <= color;
	end
endmodule // datapath
