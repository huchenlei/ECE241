`timescale 1ns / 1ns // `timescale time_unit/time_precision
// `include "hex.v"
// `include "adder.v"

module alu_v2(HEX0, HEX1, HEX2, HEX3, HEX4, HEX5, LEDR, SW, KEY);
  input [3:0] SW;
  input [3:0] KEY;

  output [9:0] LEDR;
	output [6:0] HEX0;
	output [6:0] HEX1;
	output [6:0] HEX2;
	output [6:0] HEX3;
	output [6:0] HEX4;
	output [6:0] HEX5;

	reg [9:0] temp;
	parameter zero = 4'b0000;
  parameter reset_zero = 8'b00000000;

  adder a1(SW, temp);
  reg [7:0] out; // declare the output signal for the always block
	always @( * ) // declare always block
		begin
		case (KEY[3:1])  // A+B using rippleAdder
	    3'b000: begin
        out = temp;
      end
	    3'b001: begin //1--------A+B using operator
			  out = regis[3:0] + SW[3:0];
			end
			3'b010: begin //2  ---------A OR B in the lower four bits and A XOR B in the upper four bits
				out = {regis[3:0] ^ SW [3:0], regis[3:0] | SW [3:0]};
			end
			3'b011: begin // case 3
        if(|SW)
          out = 8'b10000001;
        else
          out = reset_zero;
			end
			3'b100: begin // case 4
        if(&SW)
          out = 8'b01111110;
        else
          out = reset_zero;
      end
			3'b101: begin // 5
        SW[3:0] <<< regis[3:0];
			end
      3'b110: begin // 6
        out = SW[3:0] * regis[3:0];
      end
      3'b111: begin // 7
        // do nothing
      end
			default out = SW[0]; // default case
		endcase
	end

  reg[7:0] regis;
  reg [3:0] = zero;
  // 8bit register
  always @ ( posedge KEY[0] ) begin
    if (SW[9] == 1'b0)
      regis <= reset_zero;
    else
      regis <= out;
  end

	assign LEDR[9:0] = out;

	hex HE0(.x(SW[7:4]),.hexout(HEX0[6:0]));
	hex HE1(.x(zero[3:0]),.hexout(HEX1[6:0]));
	hex HE2(.x(SW[3:0]),.hexout(HEX2[6:0]));
	hex HE3(.x(zero[3:0]),.hexout(HEX3[6:0]));
	hex HE4(.x(LEDR[3:0]),.hexout(HEX4[6:0]));
	hex HE5(.x(LEDR[7:4]),.hexout(HEX5[6:0]));
endmodule
