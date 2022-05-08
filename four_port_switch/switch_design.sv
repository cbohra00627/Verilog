module switch(
  //Memory interface
  input mem_en,
  input mem_rw,
  input [1:0] mem_addr,
  input [7:0] mem_data,
  
  //Input port
  input [7:0] data,
  input data_status,
  
  //Output port
  output [7:0] port0,
  output [7:0] port1,
  output [7:0] port2,
  output [7:0] port3,
  output ready0,
  output ready1,
  output ready2,
  output ready3,
  input read0,
  input read1,
  input read2,
  input read3,
  
  //Clock and Reset
  input clk,
  input rst);
  
  //Port addresses
  reg [7:0] port0_addr;
  reg [7:0] port1_addr;
  reg [7:0] port2_addr;
  reg [7:0] port3_addr;
  
  //Local variables
  reg [7:0] port_0;
  reg [7:0] port_1;
  reg [7:0] port_2;
  reg [7:0] port_3;
  reg ready_0;
  reg ready_1;
  reg ready_2;
  reg ready_3;
  
  reg clk_count = 8'h00;
  reg [7:0] out_addr = 8'h00;
  reg [7:0] length = 8'h00;
    
  always @(posedge clk) begin
    
    //Resetting the port addresses
    if (rst) begin
      port0_addr = 8'h00;
      port1_addr = 8'h00;
      port2_addr = 8'h00;
      port3_addr = 8'h00;
  
      clk_count = 8'h00;
    end

    //Configure the DUT
    else if (mem_en && mem_rw) begin
      case(mem_addr)
        2'b00:  port0_addr = mem_data;
        2'b01:  port1_addr = mem_data;
        2'b10:  port2_addr = mem_data;
        2'b11:  port3_addr = mem_data;
      endcase
    end
    
    //Normal operation
    else if (data_status) begin
      
      //First byte is address byte
      if (clk_count == 8'h00) begin
        out_addr = data;
      end
      
      //Storing the length byte
      if (clk_count == 8'h02) begin
        length = data;
      end
      
      //Selecting the output port according to address
      case(out_addr)
        port0_addr: ready_0 = 1'b1;
        port1_addr: ready_1 = 1'b1;
        port2_addr: ready_2 = 1'b1;
        port3_addr: ready_3 = 1'b1;
      endcase
      
      //Sending data to selected port
      if (read0)
        port_0 = data;
      else if (read1)
        port_1 = data;
      else if (read2)
        port_2 = data;
      else if (read3)
        port_3 = data;
      
      //Decreasing data length after length field
      if (clk_count >= 8'h03)
        length = length - 1'b1;
      
      clk_count = clk_count + 1'b1;
      
    end
    
    if (length == 8'h00 && clk_count != 8'h00)
      clk_count = 8'h00;
    
  end
  
  
  assign port0 = port_0;
  assign port1 = port_1;
  assign port2 = port_2;
  assign port3 = port_3;
  assign ready0 = ready_0;
  assign ready1 = ready_1;
  assign ready2 = ready_2;
  assign ready3 = ready_3;

endmodule //switch