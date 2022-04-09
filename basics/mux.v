module MUX_2_1(out, sel, in1, in0);
	output out;
	input sel, in1, in0;

	// out = sel_bar.in0 + sel.in1
	not (sel_bar, sel);
	and (and_in0, sel_bar, in0);
	and (and_in1, sel, in1);
	or (out, and_in0, and_in1);
endmodule

module MUX_4_1(out, sel1, sel0, in3, in2, in1, in0);
	output out;
	input sel1, sel0, in3, in2, in1, in0;

	// out = sel1_bar.sel0_bar.in0 + sel1_bar.sel0.in1 + sel1.sel0_bar.in2 + sel1.sel0.in3
	not (sel0_bar, sel0);
	not (sel1_bar, sel1);
	and (and_in0, sel1_bar, sel0_bar, in0);
	and (and_in1, sel1_bar, sel0, in1);
	and (and_in2, sel1, sel0_bar, in2);
	and (and_in3, sel1, sel0, in3);
	or (out, and_in0, and_in1, and_in2, and_in3);
endmodule

/*

//To run the test uncomment this block

module test();
	wire out;
	reg sel, sel1, sel0, in3, in2, in1, in0;

	MUX_2_1 mux_21(out_21, sel, in1, in0);
	MUX_4_1 mux_41(out_41, sel1, sel0, in3, in2, in1, in0);

	initial begin

		$monitor("sel = %b | in1 = %b in0 = %b | output = %b", sel, in1, in0, out_21);

		sel = 0;
		in0 = 0;
		in1 = 0;

		#1 in1 = 1;
		#1 in0 = 1;
		#1 in1 = 0;

		#1 sel = 1;
		   in0 = 0;
		   in1 = 0;

		#1 in1 = 1;
		#1 in0 = 1;
		#1 in1 = 0;

		#1 $display("\n");

		$monitor("sel1 = %b sel0 = %b | in3 = %b in2 = %b in1 = %b in0 = %b | output = %b", sel1, sel0, in3, in2, in1, in0, out_41);

		sel0 = 0;
		sel1 = 0;
		in0 = 0;
		in1 = 0;
		in2 = 0;
		in3 = 0;

		#1 in0 = 1;
		   in3 = 1;

		#1 sel0 = 1;
		#1 in1 = 1;
		   in0 = 0;

		#1 sel1 = 1;
		#1 in3 = 0;
		   in1 = 0;

		#1 sel0 = 0;
		#1 in2 = 1;
		   in3 = 1;

		#1 $finish;
	end
	
endmodule

*/