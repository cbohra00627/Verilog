primitive NOT (out, a);
	output out;
	input a;

	table
	//	a : out
		0 : 1 ;
		1 : 0 ;
	endtable
endprimitive

primitive OR (out, a, b);
	output out;
	input a;
	input b;

	table
	//	a b : out
		0 0 : 0 ;
		1 ? : 1 ;
		? 1 : 1 ;
	endtable
endprimitive

primitive NOR (out, a, b);
	output out;
	input a;
	input b;

	table
	//	a b : out	
		0 0 : 1 ;
		1 ? : 0 ;
		? 1 : 0 ;
	endtable
endprimitive

primitive AND (out, a, b);
	output out;
	input a;
	input b;

	table
	//	a b : out	
		1 1 : 1 ;
		0 ? : 0 ;
		? 0 : 0 ;
	endtable
endprimitive

primitive NAND (out, a, b);
	output out;
	input a;
	input b;

	table
	//	a b : out	
		1 1 : 0 ;
		0 ? : 1 ;
		? 0 : 1 ;
	endtable
endprimitive

primitive XOR (out, a, b);
	output out;
	input a;
	input b;

	table
	//	a b : out	
		0 0 : 0 ;
		0 1 : 1 ;
		1 0 : 1 ;
		1 1 : 0 ;
	endtable
endprimitive

primitive XNOR (out, a, b);
	output out;
	input a;
	input b;

	table
	//	a b : out	
		0 0 : 1 ;
		0 1 : 0 ;
		1 0 : 0 ;
		1 1 : 1 ;
	endtable
endprimitive

/*

// To run the test uncomment this block.

module test();
	reg in1, in2;
	wire out1, out2, out3, out4, out5, out6, out7;

	OR (out1, in1, in2);
	NOR (out2, in1, in2);

	AND (out3, in1, in2);
	NAND (out4, in1, in2);

	XOR (out5, in1, in2);
	XNOR (out6, in1, in2);

	NOT (out7, in1);

	initial begin
		$monitor("in1 = %b  in2 = %b | OR = %b NOR = %b", in1, in2, out1, out2);
		in1 = 0;
		in2 = 0;

		#1 in2 = 1;
		#1 in1 = 1;
		#1 in2 = 0;

		#1 $display("\n");

		$monitor("in1 = %b  in2 = %b | AND = %b NAND = %b", in1, in2, out3, out4);
		in1 = 0;
		in2 = 0;

		#1 in2 = 1;
		#1 in1 = 1;
		#1 in2 = 0;

		#1 $display("\n");

		$monitor("in1 = %b  in2 = %b | XOR = %b XNOR = %b", in1, in2, out5, out6);
		in1 = 0;
		in2 = 0;

		#1 in2 = 1;
		#1 in1 = 1;
		#1 in2 = 0;

		#1 $display("\n");

		$monitor("in1 = %b | NOT = %b", in1, out7);
		in1 = 0;

		#1 in1 = 1;

		#1 $finish;
	end
	
endmodule

*/