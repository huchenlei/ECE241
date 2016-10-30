// SW[3:0] divisor value
// SW[7:4] divident value
// CLOCK_50 clock signal
// KEY[0] active_high reset
// KEY[1] go signal to start computation
// HEX0 devisor
// HEX2 devident
// HEX4 quotient
// HEX5 remainder
// LEDR[3:0] quotient

module division_top (SW, KEY, CLOCK_50, LEDR, HEX0, HEX1, HEX2, HEX3, HEX4, HEX5);
  input [7:0] SW;
  input [1:0] KEY;
  input CLOCK_50;
  output [6:0] HEX0, HEX1, HEX2, HEX3, HEX4, HEX5;
  output [3:0] LEDR;

  wire go;
  wire resetn;
  wire [7:0] data_result;

  assign go = ~KEY[1];
  assign resetn = KEY[0];// active_high?

  devision_main m0(
    .clk(CLOCK_50),
    .resetn(resetn),
    .go(go),
    .data_in(SW[7:0]),
    .data_result(data_result)
  );

  assign LEDR[3:0] = data_result[3:0];

  parameter zero_display = 4'b0000;
  hex_decoder h0(SW[3:0], HEX0);
  hex_decoder h1(zero_display, HEX1);
  hex_decoder h2(SW[7:4], HEX2);
  hex_decoder h3(zero_display, HEX3);
  hex_decoder h4(data_result[3:0], HEX4);
  hex_decoder h5(data_result[7:4], HEX5);

endmodule // devision_top

module devision_main (
  input clk,
  input resetn,
  input go,
  input [7:0] data_in,
  output [7:0] data_result
  );

  // control wires
  wire ld_data;
  wire ld_r;
  wire ld_q0;
  wire set_q0;
  wire ld_end;
  wire ld_a;
  wire q0;
  wire [1:0] alu_op;

  control c0(clk, resetn, go, q0, ld_data, ld_q0, set_q0,
            ld_r, ld_end, ld_a, alu_op);
  datapath d0(clk, resetn, data_in, ld_data, alu_op,
            set_q0, ld_q0, ld_r, ld_end, ld_a, q0, data_result);
endmodule // devision_main

module control (
  input clk,
  input resetn,
  input go,
  input q0,

  output reg ld_data,
  output reg ld_q0, set_q0,
  output reg ld_r,
  output reg ld_end,
  output reg ld_a,
  output reg [1:0] alu_op
  );

  reg[1:0] loop_count;
  reg[5:0] current_state, next_state;

  localparam  S_LOAD_DATA = 5'd0,
              S_LOAD_DATA_WAIT = 5'd1,
              S_CYCLE_0 = 5'd2,
              S_CYCLE_1 = 5'd3,
              S_CYCLE_2 = 5'd4,
              S_CYCLE_3 = 5'd5;

  // Next state logic table
  always @ ( * )
  begin: state_table
    $display("[StateTable]The current state is %d", current_state);
    $display("[StateTable]The loop count is %d", loop_count);
    case(current_state)
      S_LOAD_DATA: next_state = go ? S_LOAD_DATA_WAIT : S_LOAD_DATA;
      S_LOAD_DATA_WAIT: begin
        next_state = go ? S_LOAD_DATA_WAIT : S_CYCLE_0;
        loop_count = 2'b0;
      end
      S_CYCLE_0: next_state = S_CYCLE_1;
      S_CYCLE_1: next_state = S_CYCLE_2;
      S_CYCLE_2: next_state = S_CYCLE_3;
      S_CYCLE_3: begin
        if(loop_count == 2'b11) begin
          next_state = S_LOAD_DATA;
          ld_r = 1'b1;
        end
        else begin
          next_state = S_CYCLE_0;
          loop_count = loop_count + 1;
        end
      end
      default: next_state = S_LOAD_DATA;
    endcase
    $display("[StateTable]The next state would be %d", next_state);
  end

  always @ ( * )
  begin: enable_signals
    // by default make all signals 0
    ld_data = 1'b0;
    ld_q0 = 1'b0;
    set_q0 = 1'b0;
    alu_op = 2'b00;

    case (current_state)
      S_LOAD_DATA: ld_data = 1'b1;
      S_CYCLE_0: begin // do shifting left
        alu_op = 2'b10; // shifting
        ld_a = 1'b1;
        ld_end = 1'b1; // load result back to a and divident
      end
      S_CYCLE_1: begin // subtract devisor from reg A and get MSB to q0
        alu_op = 2'b01; // subtracting
        ld_q0 = 1'b1;
        ld_a = 1'b1; // load result back to a
      end
      S_CYCLE_2: begin // if q0 == 1 then add back, else do nothing
        if(q0 == 1'b1) begin
          alu_op = 2'b00; // adding
          ld_a = 1'b1; // load result back to a
        end
      end
      S_CYCLE_3: begin // set q0 to 0 or 1
        set_q0 = 1'b1;
      end
    endcase

    // current_state registers
    always@(posedge clk)
    begin: state_FFs
        if(!resetn)
            current_state <= S_LOAD_A;
        else
            current_state <= next_state;
    end // state_FFS

    $display("[EnableSignals]");
    $display("ld_data is %b", ld_data);
    $display("ld_q0 is %b", ld_q0);
    $display("set_q0 is %b", set_q0);
    $display("alu_op is %b", alu_op);
  end
endmodule // control

module datapath (
  input clk,
  input resetn,
  input [7:0] data_in,
  input ld_data,
  input [1:0] alu_op,
  input set_q0, ld_q0,
  input ld_r,
  input ld_end,
  input ld_a,

  output reg q0,
  output reg [7:0] data_result
  );

  // input registers
  reg [3:0] divisor;
  reg [3:0] divident;

  // remainder holder
  reg [4:0] a;

  // alu input signals
  reg [4:0] alu_a;
  reg [3:0] alu_b;

  // load data
  always @ ( posedge clk ) begin
    if(!resetn) begin
      $display("[Data Reset]Resetting all regs");
      divisor <= 4'b0;
      divident <= 4'b0;
      a <= 5'b0;
    end
    else begin
      if(ld_data) begin
        $display("[Data Load] Loading data");
        divisor <= data_in[3:0];
        divident <= data_in[7:4];
      end
      if(ld_end) begin
        $display("[Data Load] load divident %b", alu_b);
        divident <= alu_b;
      end
      if(ld_a) begin
        $display("[Data Load] load a %b", alu_a);
        a <= alu_a;
      end
      if(ld_q0) begin
        $display("[Data Load] loading q0 %b", q0);
        q0 <= a[4];
      end
      if(set_q0) begin
        $display("[Data Load] setting q0 %b", divident[0]);
        divident[0] = q0;
      end
    end
  end

  // output result register
  always @ (posedge clk) begin
    if(!resetn) begin
      data_result <= 8'b0;
    end
    else begin
      if(ld_r) begin
        data_result <= {a[3:0], divident[3:0]};
        $display("[Result display] %b", data_result);
      end
    end
  end

  // The alu
  always @ ( * ) begin
    case (alu_op)
      2'd0: begin
        alu_a = a + divisor;
        $display("[ALU] a + divisor = %b", a);
      end
      2'd1: begin
        alu_a = a - divisor;
        $display("[ALU] a - divisor = %b", a);
      end
      2'd2: begin
        {alu_a, alu_b} = {a, divident} << 1;
        $display("[ALU] shifting result %b", {a, divident});
      end
      default: begin
		  alu_a = 5'b0;
		  alu_b = 4'b0;
		end
    endcase
  end
endmodule // datapath

module hex_decoder(hex_digit, segments);
    input [3:0] hex_digit;
    output reg [6:0] segments;

    always @(*)
        case (hex_digit)
            4'h0: segments = 7'b100_0000;
            4'h1: segments = 7'b111_1001;
            4'h2: segments = 7'b010_0100;
            4'h3: segments = 7'b011_0000;
            4'h4: segments = 7'b001_1001;
            4'h5: segments = 7'b001_0010;
            4'h6: segments = 7'b000_0010;
            4'h7: segments = 7'b111_1000;
            4'h8: segments = 7'b000_0000;
            4'h9: segments = 7'b001_1000;
            4'hA: segments = 7'b000_1000;
            4'hB: segments = 7'b000_0011;
            4'hC: segments = 7'b100_0110;
            4'hD: segments = 7'b010_0001;
            4'hE: segments = 7'b000_0110;
            4'hF: segments = 7'b000_1110;
            default: segments = 7'h7f;
        endcase
endmodule
