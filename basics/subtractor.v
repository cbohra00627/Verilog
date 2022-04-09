module HALF_SUBTRACTOR(diff, borrow, a, b);
	output diff, borrow;
	input a, b;

	// difference = a xor b ; borrow = a_bar and b
	xor (diff, a, b);
	not (a_bar, a);
	and (borrow, a_bar, b);
endmodule

module FULL_SUBTRACTOR(diff, borrow, a, b, borrow_in);
	output diff, borrow;
	input a, b, borrow_in;

	// sum = a xor b xor borrow_in ; borrow = a_bar.b + a_bar.borrow_in + b.borrow_in
	xor (diff, a, b, borrow_in);
	not (a_bar, a);
	and (and0, a_bar, b);
	and (and1, a_bar, borrow_in);
	and (and2, b, borrow_in);
	or (borrow, and0, and1, and2);
endmodule

/*

//To run the test uncomment this block

module test();
	wire diff_half, diff_full, borrow_half, borrow_full;
	reg a, b, borrow_in;

	HALF_SUBTRACTOR half_sub(diff_half, borrow_half, a, b);
	FULL_SUBTRACTOR full_sub(diff_full, borrow_full, a, b, borrow_in);

	initial begin
		
		$monitor("A = %b B = %b | difference = %b borrow = %b", a, b, diff_half, borrow_half);
		a = 0;
		b = 0;

		#1 b = 1;
		#1 a = 1;
		   b = 0;
		#1 b = 1;

		#1 $display("\n");

		$monitor("A = %b B = %b borrow_in = %b | difference = %b borrow = %b", a, b, borrow_in, diff_full, borrow_full);
		a = 0;
		b = 0;
		borrow_in = 0;

		#1 borrow_in = 1;
		#1 b = 1;
		   borrow_in = 0;
		#1 borrow_in = 1;
		#1 a = 1;
		   b = 0;
		   borrow_in = 0;
		#1 borrow_in = 1;
		#1 b = 1;
		   borrow_in = 0;
		#1 borrow_in = 1;
	end

endmodule

*/