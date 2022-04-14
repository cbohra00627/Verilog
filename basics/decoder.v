module DECODER_1_2(
	output reg [1:0] out,
	input in,
	input enable);

	always @ (in or enable) begin
		out = 2'b00;
		if (enable) begin
			case (in)
				1'b0 : out = 2'b00;
				1'b1 : out = 2'b01;
				default : out = 2'b00;
			endcase
		end
	end

endmodule

module DECODER_2_4(
	output reg [3:0] out,
	input [1:0] in,
	input enable);

	always @ (in or enable) begin
		out = 4'b0000;
		if (enable) begin
			case (in)
				2'b00 : out = 4'b0000;
				2'b01 : out = 4'b0001;
				2'b10 : out = 4'b0010;
				2'b11 : out = 4'b0100;
				default : out = 4'b0000;
			endcase
		end
	end

endmodule

module DECODER_3_8(
	output reg [7:0] out,
	input [2:0] in,
	input enable);

	always @ (in or enable) begin
		out = 8'b00000000;
		if (enable) begin
			case (in)
				8'b000 : out = 8'b00000000;
				8'b001 : out = 8'b00000001;
				8'b010 : out = 8'b00000010;
				8'b011 : out = 8'b00000100;
				8'b100 : out = 8'b00001000;
				8'b101 : out = 8'b00010000;
				8'b110 : out = 8'b00100000;
				8'b111 : out = 8'b01000000;
				default : out = 8'b00000000;
			endcase
		end
	end

endmodule

module DECODER_4_16(
	output reg [15:0] out,
	input [3:0] in,
	input enable);

	always @ (in or enable) begin
		out = 4'b0000;
		if (enable) begin
			case (in)
				4'b0000 : out = 16'h0000;
				4'b0001 : out = 16'h0001;
				4'b0010 : out = 16'h0002;
				4'b0011 : out = 16'h0004;
				4'b0100 : out = 16'h0008;
				4'b0101 : out = 16'h0010;
				4'b0110 : out = 16'h0020;
				4'b0111 : out = 16'h0040;
				4'b1000 : out = 16'h0080;
				4'b1001 : out = 16'h0100;
				4'b1010 : out = 16'h0200;
				4'b1011 : out = 16'h0400;
				4'b1100 : out = 16'h0800;
				4'b1101 : out = 16'h1000;
				4'b1110 : out = 16'h2000;
				4'b1111 : out = 16'h4000;
				default : out = 16'h0000;
			endcase
		end
	end

endmodule

//To run the test uncomment this block

module test();


	wire [1:0] out2;
	wire [3:0] out4;
	wire [7:0] out8;
	wire [15:0] out16;

	reg in1;
	reg [1:0] in2;
	reg [2:0] in3;
	reg [3:0] in4;

	reg enable;

	DECODER_1_2 dec_1_2(out2, in1, enable);
	DECODER_2_4 dec_2_4(out4, in2, enable);
	DECODER_3_8 dec_3_8(out8, in3, enable);
	DECODER_4_16 dec_4_16(out16, in4, enable);

	initial begin
		
		enable = 1;

		#1 $display("\n1:2 Decoder");
		   $monitor("input = %b | output = %b",in1, out2);

		   in1 = 1'b0;
		#1 in1 = 1'b1;

		#1 $display("\n2:4 Decoder");
		   $monitor("input = %b | output = %b",in2, out4);

		   in2 = 4'b00;
		#1 in2 = 4'b01;
		#1 in2 = 4'b10;
		#1 in2 = 4'b11;

		#1 $display("\n3:8 Decoder");
		   $monitor("input = %b | output = %b",in3, out8);

		   in3 = 3'b000;
		#1 in3 = 3'b001;
		#1 in3 = 3'b010;
		#1 in3 = 3'b011;
		#1 in3 = 3'b100;
		#1 in3 = 3'b101;
		#1 in3 = 3'b110;
		#1 in3 = 3'b111;

		#1 $display("\n4:16 Decoder");
		   $monitor("input = %b | output(in hex) = %h",in4, out16);

		   in4 = 4'b0000;
		#1 in4 = 4'b0001;
		#1 in4 = 4'b0010;
		#1 in4 = 4'b0011;
		#1 in4 = 4'b0100;
		#1 in4 = 4'b0101;
		#1 in4 = 4'b0110;
		#1 in4 = 4'b0111;
		#1 in4 = 4'b1000;
		#1 in4 = 4'b1001;
		#1 in4 = 4'b1010;
		#1 in4 = 4'b1011;
		#1 in4 = 4'b1100;
		#1 in4 = 4'b1101;
		#1 in4 = 4'b1110;
		#1 in4 = 4'b1111;

	end 

endmodule