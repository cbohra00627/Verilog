module PIPO_register(out, data, clk, rst, load);
	output reg [3:0] out;

	input [3:0] data;
	input clk;
	input rst;
	input load;

	always @ (posedge clk) begin
		if (rst) begin
			out <= 4'b0;
		end
		else if (load) begin
			out <= data;
		end
	end
endmodule

module SISO_registor(out, q, clk, rst);
	output reg out;

	input q;
	input clk;
	input rst;

	reg [3:0] buff;

	always @ (posedge clk) begin
		if (rst) begin
			buff <= 4'b0;
			out <= 1'b0;
		end
		else begin
			out = buff[3];
			buff <= {buff[2:0], q};
		end
	end
endmodule

module PISO_register(out, data, clk, rst, load, shift_enable);
	output reg out;

	input [3:0] data;
	input clk;
	input rst;
	input load;
	input shift_enable;

	reg [3:0] buff;

	always @ (posedge clk) begin
		if (rst) begin
			buff <= 4'b0;
			out <= 1'b0;
		end
		else if (load) begin
			buff <= data;
		end
		else if (shift_enable) begin
			out = buff[3];
			buff <= {buff[2:0], 1'b0};
		end
	end
endmodule

module SIPO_register(out, q, clk, rst, load, shift_enable);
	output reg [3:0] out;

	input q;
	input clk;
	input rst;
	input load;
	input shift_enable;

	reg [3:0] buff;

	always @ (posedge clk) begin
		if (rst) begin
			buff <= 4'b0;
			out = 4'b0;
		end
		else if (load) begin
			out <= buff;
		end
		else if (shift_enable) begin
			buff = {buff[2:0], q};
		end
	end
endmodule

module test();

	wire [3:0] out_pipo;
	wire out_siso;
	wire out_piso;
	wire [3:0] out_sipo;

	reg [3:0] data;
	reg q;
	reg clk;
	reg rst_pipo, rst_siso, rst_piso, rst_sipo;
	reg load_pipo, load_piso, load_sipo;
	reg shift_enable_piso, shift_enable_sipo;
	
	integer i;

	PIPO_register PIPO(.out (out_pipo), .data (data), .clk (clk), .rst (rst_pipo), .load (load_pipo));
	SISO_registor SISO(.out (out_siso), .q (q), .clk(clk), .rst (rst_siso));
	PISO_register PISO(.out (out_piso), .data (data), .clk (clk), .rst (rst_piso), .load (load_piso), .shift_enable (shift_enable_piso));
	SIPO_register SIPO(.out (out_sipo), .q (q), .clk (clk), .rst (rst_sipo), .load (load_sipo), .shift_enable (shift_enable_sipo));

	always #5 clk = ~clk;

	initial begin

        clk = 1;
		data = 4'b1010;

		$display("PIPO:");
		$monitor("data = %b reset = %b load = %b | output = %b", data, rst_pipo, load_pipo, out_pipo);
		   rst_pipo = 1'b1;
		   load_pipo = 1'b0;
		#10 rst_pipo = 1'b0;
		   load_pipo = 1'b1;
		#10 load_pipo = 1'b0;

		#50 $display("\nSISO:");
		$monitor("q = %b reset = %b | output = %b", q, rst_siso, out_siso);
		   q = 1'b0;
		   rst_siso = 1'b1;
		#10 rst_siso = 1'b0;
		for (i=3; i>=0; i = i - 1) begin
			#10 q = data[i];
		end
		for (i=3; i>=0; i = i - 1) begin
			#10 q = 1'b0;
		end

		#50 $display("\nPISO:");
		$monitor("data = %b reset = %b load = %b shift_enable = %b | output = %b", data, rst_piso, load_piso, shift_enable_piso, out_piso);
		   rst_piso = 1'b1;
		   load_piso = 1'b0;
		   shift_enable_piso = 1'b0;
		#10 rst_piso = 1'b0;
		   load_piso = 1'b1;
		#10 load_piso = 1'b0;
		   shift_enable_piso = 1'b1;

		#50 $display("\nSIPO:");
		$monitor("q = %b reset = %b load = %b shift_enable_sipo = %b | output = %b", q, rst_sipo, load_sipo, shift_enable_sipo, out_sipo);
		   q = 1'b0;
		   rst_sipo = 1'b1;
		   load_sipo = 1'b0;
		   shift_enable_sipo = 1'b0;
		#10 rst_sipo = 1'b0;
		#10 shift_enable_sipo = 1'b1;
		for (i=3; i>=0; i = i - 1) begin
			#10 q = data[i];
		end
		#10 shift_enable_sipo = 1'b0;
		   load_sipo = 1'b1;

		#10 $finish;

	end
endmodule