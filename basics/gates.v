primitive NOT (out, a);
	output out;
	input a;

	table
	//	a : out
		0 : 1 ;
		1 : 0 ;
	endtable
endprimitive

primitive OR_2B (out, a, b);
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

primitive NOR_2B (out, a, b);
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

primitive AND_2B (out, a, b);
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

primitive NAND_2B (out, a, b);
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

primitive XOR_2B (out, a, b);
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

primitive XNOR_2B (out, a, b);
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