module HALF_ADDER(sum, carry, a, b);
	output sum, carry;
	input a, b;

	// sum = a xor b ; carry = a and b
	xor (sum, a, b);
	and (carry, a, b);
endmodule

module FULL_ADDER(sum, carry, a, b, carry_in);
	output sum, carry;
	input a, b, carry_in;

	// sum = a xor b xor carry_in ; carry = a.b + b.carry_in + carry_in.a
	xor (sum, a, b, carry_in);
	and (and0, a, b);
	and (and1, b, carry_in);
	and (and2, carry_in, a);
	or (carry, and0, and1, and2);
endmodule

/*

//To run the test uncomment this block

module test();
	wire sum_half, sum_full, carry_half, carry_full;
	reg a, b, carry_in;

	HALF_ADDER half_adder(sum_half, carry_half, a, b);
	FULL_ADDER full_adder(sum_full, carry_full, a, b, carry_in);

	initial begin
		
		$monitor("A = %b B = %b | sum = %b carry = %b", a, b, sum_half, carry_half);
		a = 0;
		b = 0;

		#1 b = 1;
		#1 a = 1;
		   b = 0;
		#1 b = 1;

		#1 $display("\n");

		$monitor("A = %b B = %b carry_in = %b | sum = %b carry = %b", a, b, carry_in, sum_full, carry_full);
		a = 0;
		b = 0;
		carry_in = 0;

		#1 carry_in = 1;
		#1 b = 1;
		   carry_in = 0;
		#1 carry_in = 1;
		#1 a = 1;
		   b = 0;
		   carry_in = 0;
		#1 carry_in = 1;
		#1 b = 1;
		   carry_in = 0;
		#1 carry_in = 1;
	end

endmodule

*/