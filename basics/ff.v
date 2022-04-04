primitive d_latch(q, clk, d);
	output q;
	input clk, d;

	reg q;

	table
	// clk d   q   q+
		0  1 : ? : 1 ;
		0  0 : ? : 0 ;
		1  ? : ? : - ;
	endtable
endprimitive

primitive d_ff(q, clk, d);
	output q;
	input clk, d;

	reg q;

	table
	// clk d   q   q+
		r  0 : ? : 0 ;
		r  1 : ? : 1 ;
		f  ? : ? : - ;
		?  * : ? : - ;
	endtable
endprimitive

primitive sr_ff(q, s, r);
	output q;
	input s, r;

	reg q;

	table
	//  s r   q   q+
		1 0 : ? : 1 ;
		f 0 : 1 : - ;
		0 r : ? : 0 ;
		0 f : 0 : - ;
		1 1 : ? : 0 ;
	endtable
endprimitive

primitive jk_ff(q, clk, j, k);
	output q;
	input clk, j, k;

	reg q;

	table
	// clk j k   q   q+
		r  0 0 : ? : - ;
		r  0 1 : ? : 0 ;
		r  1 0 : ? : 1 ;
		r  1 1 : 0 : 1 ;
		r  1 1 : 1 : 0 ;
		f  ? ? : ? : - ;
		?  * ? : ? : - ;
		?  ? * : ? : - ;
	endtable
endprimitive