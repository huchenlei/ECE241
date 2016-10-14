module adder(out_ra, in_ra);
  input [9:0] in_ra;
  output [9:0] out_ra;
  wire w1,w2,w3;

  fullAdder m1(
			.x(in_ra[0]),
			.y(in_ra[4]),
			.cin(in_ra[8]),
			.cout(w1),
			.s(out_ra[0])

	 );

	 fullAdder m2(
			.x(in_ra[1]),
			.y(in_ra[5]),
			.cin(w1),
			.cout(w2),
			.s(out_ra[1])

	 );

	 fullAdder m3(
			.x(in_ra[2]),
			.y(in_ra[6]),
			.cin(w2),
			.cout(w3),
			.s(out_ra[2])

	 );

	 fullAdder m4(
			.x(in_ra[3]),
			.y(in_ra[7]),
			.cin(w3),
			.cout(out_ra[9]),
			.s(out_ra[3])

	 );



endmodule




module fullAdder(x,y,cin,cout,s);

	 input x;
	 input y;
	 input cin;
	 output cout;
	 output s;

	 assign cout = (y & cin) | (y & x) | (cin & x);
	 assign s = (~cin & ~x & y) | (~cin & x & ~y) | (cin & ~x & ~y ) | (cin & x & y);

endmodule
