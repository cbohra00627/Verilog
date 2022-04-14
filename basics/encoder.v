module ENCODER_2_1(
	output reg out,
	input [1:0] in,
	input enable);

	always @ (in or enable) begin
		out = 1'b0;
		if (enable) begin
			case (in)
				2'b00 : out = 1'b0;
				2'b10 : out = 1'b1;
				default : out = 1'b0;
			endcase
		end
	end

endmodule

module ENCODER_4_2(
	output reg [1:0] out,
	input [3:0] in,
	input enable);

	always @ (in or enable) begin
		out = 2'b00;
		if (enable) begin
			case (in)
				4'b0000 : out = 2'b00;
				4'b0001 : out = 2'b01;
				4'b0010 : out = 2'b10;
				4'b0100 : out = 2'b11;
				default : out = 2'b00;
			endcase
		end
	end

endmodule

module ENCODER_8_3(
	output reg [2:0] out,
	input [7:0] in,
	input enable);

	always @ (in or enable) begin
		out = 3'b000;
		if (enable) begin
			case (in)
				8'b00000000 : out = 3'b000;
				8'b00000001 : out = 3'b001;
				8'b00000010 : out = 3'b010;
				8'b00000100 : out = 3'b011;
				8'b00001000 : out = 3'b100;
				8'b00010000 : out = 3'b101;
				8'b00100000 : out = 3'b110;
				8'b01000000 : out = 3'b111;
				default : out = 3'b000;
			endcase
		end
	end

endmodule

module ENCODER_16_4(
	output reg [3:0] out,
	input [15:0] in,
	input enable);

	always @ (in or enable) begin
		out = 4'b0000;
		if (enable) begin
			case (in)
				16'h0000 : out = 4'b0000;
				16'h0001 : out = 4'b0001;
				16'h0002 : out = 4'b0010;
				16'h0004 : out = 4'b0011;
				16'h0008 : out = 4'b0100;
				16'h0010 : out = 4'b0101;
				16'h0020 : out = 4'b0110;
				16'h0040 : out = 4'b0111;
				16'h0080 : out = 4'b1000;
				16'h0100 : out = 4'b1001;
				16'h0200 : out = 4'b1010;
				16'h0400 : out = 4'b1011;
				16'h0800 : out = 4'b1100;
				16'h1000 : out = 4'b1101;
				16'h2000 : out = 4'b1110;
				16'h4000 : out = 4'b1111;
				default : out = 4'b0000;
			endcase
		end
	end

endmodule

module PRIORITY_ENCODER_16_4(
	output reg [3:0] out,
	input [15:0] in,
	input enable);

	always @ (in or enable) begin
		out = 4'b0000;
		if (enable) begin
			casex (in)
				16'b0000000000000000 : out = 4'b0000;
				16'b0000000000000001 : out = 4'b0001;
				16'b000000000000001x : out = 4'b0010;
				16'b00000000000001xx : out = 4'b0011;
				16'b0000000000001xxx : out = 4'b0100;
				16'b000000000001xxxx : out = 4'b0101;
				16'b00000000001xxxxx : out = 4'b0110;
				16'b0000000001xxxxxx : out = 4'b0111;
				16'b000000001xxxxxxx : out = 4'b1000;
				16'b00000001xxxxxxxx : out = 4'b1001;
				16'b0000001xxxxxxxxx : out = 4'b1010;
				16'b000001xxxxxxxxxx : out = 4'b1011;
				16'b00001xxxxxxxxxxx : out = 4'b1100;
				16'b0001xxxxxxxxxxxx : out = 4'b1101;
				16'b001xxxxxxxxxxxxx : out = 4'b1110;
				16'b01xxxxxxxxxxxxxx : out = 4'b1111;
				default : out = 4'b0000;
			endcase
		end
	end

endmodule

//To run the test uncomment this block

module test();


	wire out1;
	wire [1:0] out2;
	wire [2:0] out3;
	wire [3:0] out4;
	wire [3:0] out4_pri;

	reg [1:0] in2;
	reg [3:0] in4;
	reg [7:0] in8;
	reg [15:0] in16;
	reg [15:0] in16_pri;

	reg enable;

	ENCODER_2_1 enc_2_1(out1, in2, enable);
	ENCODER_4_2 enc_4_2(out2, in4, enable);
	ENCODER_8_3 enc_8_3(out3, in8, enable);
	ENCODER_16_4 enc_16_4(out4, in16, enable);
	PRIORITY_ENCODER_16_4 pri_enc_16_4(out4_pri, in16_pri, enable);

	initial begin
		
		enable = 1;

		#1 $display("\n2:1 Encoder");
		   $monitor("input = %b | output = %b",in2, out1);

		   in2 = 2'b00;
		#1 in2 = 2'b10;
		#1 in2 = 2'b11;

		#1 $display("\n4:2 Encoder");
		   $monitor("input = %b | output = %b",in4, out2);

		   in4 = 4'b0000;
		#1 in4 = 4'b0001;
		#1 in4 = 4'b0010;
		#1 in4 = 4'b0100;
		#1 in4 = 4'b0110;

		#1 $display("\n8:3 Encoder");
		   $monitor("input = %b | output = %b",in8, out3);

		   in8 = 8'b00000000;
		#1 in8 = 8'b00000001;
		#1 in8 = 8'b00000010;
		#1 in8 = 8'b00000100;
		#1 in8 = 8'b00001000;
		#1 in8 = 8'b00010000;
		#1 in8 = 8'b00100000;
		#1 in8 = 8'b01000000;
		#1 in8 = 8'b10000000;

		#1 $display("\n16:4 Encoder");
		   $monitor("input = %h | output = %b",in16, out4);

		   in16 = 16'h0000;
		#1 in16 = 16'h0001;
		#1 in16 = 16'h0002;
		#1 in16 = 16'h0004;
		#1 in16 = 16'h0008;
		#1 in16 = 16'h0010;
		#1 in16 = 16'h0020;
		#1 in16 = 16'h0040;
		#1 in16 = 16'h0080;
		#1 in16 = 16'h0100;
		#1 in16 = 16'h0200;
		#1 in16 = 16'h0400;
		#1 in16 = 16'h0800;
		#1 in16 = 16'h1000;
		#1 in16 = 16'h2000;
		#1 in16 = 16'h4000;
		#1 in16 = 16'h8040;

		#1 $display("\n16:4 Priority Encoder");
		   $monitor("input = %b | output = %b",in16_pri, out4_pri);

		   in16_pri = 16'b0000000000000000;
		#1 in16_pri = 16'b0000000000000001;
		#1 in16_pri = 16'b0000000000000010;
		#1 in16_pri = 16'b0000000000000100;
		#1 in16_pri = 16'b0000000000001000;
		#1 in16_pri = 16'b0000000000010000;
		#1 in16_pri = 16'b0000000000100000;
		#1 in16_pri = 16'b0000000001000000;
		#1 in16_pri = 16'b0000000010000000;
		#1 in16_pri = 16'b0000000100000000;
		#1 in16_pri = 16'b0000001000011000;
		#1 in16_pri = 16'b00000111000010x0;
		#1 in16_pri = 16'b00001110000xx0xx;
		#1 in16_pri = 16'b0001x10000001100;
		#1 in16_pri = 16'b00110001xx001111;
		#1 in16_pri = 16'b01111100000xxxxx;
		#1 in16_pri = 16'b10111100000xxxxx;

		#1 $finish;

	end 

endmodule