primitive mux_2_1(out, sel, in0, in1);
	output out;
	input sel, in0, in1;

	table
	// sel in0 in1   out
		0   0   ?  :  0 ;
		0   1   ?  :  1 ;
		1   ?   0  :  0 ;
		1   ?   1  :  1 ;
		?   0   0  :  0 ;
		?   1   1  :  1 ;
	endtable
endprimitive


/*

//Uncomment the block to run test

module test();
	wire out;
	reg sel, in0, in1;

	mux_2_1(out, sel, in0, in1);

	initial begin

		sel = 0;
		in0 = 0;
		in1 = 0;

		$monitor("sel = %b in0 = %b in1 = %b | output = %b", sel, in0, in1, out);

		#1 in1 = 1;
		#1 in0 = 1;
		#1 in1 = 0;

		#1 sel = 1;
		in0 = 0;
		in1 = 0;

		#1 in1 = 1;
		#1 in0 = 1;
		#1 in1 = 0;

		#1 $finish;
	end
endmodule

*/