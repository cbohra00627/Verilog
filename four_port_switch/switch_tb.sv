//Global variables
`define P0 8'h00
`define P1 8'h11
`define P2 8'h22
`define P3 8'h33

int error = 0;      //Counts errors
int num_pkt = 10;   //Total number of packets to be tested

//Enumerated types for packet length
typedef enum {GOOD_LENGTH, BAD_LENGTH} length_type;

//Memory interface
interface MEM_INTF(input bit clk);
  logic [7:0] mem_data;
  logic [1:0] mem_addr;
  logic mem_en;
  logic mem_rw;

  clocking cb @(posedge clk);
    default input #1 output #1;
    output mem_data;
    output mem_addr;
    output mem_en;
    output mem_rw;
  endclocking //cb

  modport MEM(clocking cb,input clk);

endinterface //MEM_INTF

//Input interface
interface INPUT_INTF(input bit clk);
  logic [7:0] data;
  logic data_status;
  logic rst;

  clocking cb @(posedge clk);
    default input #1 output #1;
    output    data_status;
    output    data;
  endclocking //cb

  modport IP(clocking cb,output rst,input clk);

endinterface //INPUT_INTF

//Output interface
interface OUTPUT_INTF(input bit clk);
  logic [7:0] port;
  logic ready;
  logic read;

  clocking cb @(posedge clk);
    default input #1 output #1;
    output read;
    input port;
    input ready;
  endclocking //cb

  modport OP(clocking cb,input clk);

endinterface //OUTPUT_INTF


//Pakcet class
class Packet;
  
  //Randomizing message fields
  rand length_type length_kind;
  rand bit [7:0] da;        //Destination address
  rand bit [7:0] sa;        //Source address
  rand bit [7:0] length;    //Message length
  rand byte data[];         //Message dynamic array
  
  //Constraints
  constraint address_c {da inside {`P0, `P1, `P2, `P3};}
  constraint message_size_c {data.size inside {[1:255]};}
  constraint length_kind_c {
    (length_kind == GOOD_LENGTH) -> length == data.size;
    (length_kind == BAD_LENGTH) -> length == data.size + 2;}
  constraint solve_size_length {solve data.size before length;}
  
  //Method to print packet fields
  virtual function void display();
    $display("\n***************** PACKET ******************* ");
    $display("length_kind:  ", length_kind.name());
    $display("da (0) : %h", da);
    $display("sa (1) : %h", sa);
    $display("length (2) : %0d", length);
    foreach(data[i])
      $write("data[%0d] : %h | ", i+3, data[i]);
    $display("\n ***************** PACKET END  ******************* \n");
  endfunction : display
  
  //Pack the packet into bytes
  virtual function int unsigned byte_pack(ref logic [7:0] bytes[]);
    bytes = new[data.size + 3];
    bytes[0] = da;
    bytes[1] = sa;
    bytes[2] = length;
    foreach(data[i])
      bytes[i+3] = data[i];
    byte_pack = bytes.size;
  endfunction : byte_pack
  
  //Method to unpack the byte
  virtual function void byte_unpack(const ref logic [7:0] bytes[]);
    this.da = bytes[0];
    this.sa = bytes[1];
    this.length = bytes[2];
    this.data = new[bytes.size - 3];
    foreach(data[i])
      data[i] = bytes[i + 3];
  endfunction : byte_unpack
  
  //Method to compare the packets
  virtual function bit compare(Packet pkt);
  compare = 1'b1;
    if(pkt == null) begin
        $display("**ERROR** : pkt : Received a null object ");
        compare = 1'b0;
    end
    else begin
      if(pkt.da !== this.da) begin
        $display("**ERROR**: pkt : Da field did not match");
        compare = 1'b0;
      end
      if(pkt.sa !== this.sa) begin
        $display("**ERROR**: pkt : Sa field did not match");
        compare = 1'b0;
      end
      if(pkt.length !== this.length) begin
        $display("**ERROR**: pkt : Length field did not match");
        compare = 1'b0;
      end
      foreach(this.data[i])
        if(pkt.data[i] !== this.data[i]) begin
          $display("**ERROR**: pkt : Data[%0d] field did not match",i);
          compare = 1'b0;
        end
     end
  endfunction : compare

endclass //Packet

//Driver class
class Driver;
  virtual INPUT_INTF.IP input_intf;
  mailbox driver2sb;
  Packet gpkt;
  
  //Constructor
  function new(virtual INPUT_INTF.IP input_intf_new, mailbox driver2sb);
    this.input_intf = input_intf_new;
    if(driver2sb == null) begin
      $display("**ERROR**: driver2sb is null");
      $finish;
    end
    else
      this.driver2sb = driver2sb;
  endfunction : new

  //Method to send packet to DUT
  task start();
    Packet pkt;
    int length;
    logic [7:0] bytes[];
    
    repeat(num_pkt) begin
      repeat(3) @(posedge input_intf.clk);
      pkt = new gpkt;
    
      //Randomize the packet
      if (pkt.randomize()) begin
        $display ("%0d : Driver : Randomization Successfull.",$time);
       
        //Display the packet content
        pkt.display();

        //Pack the packet in tp stream of bytes
        length = pkt.byte_pack(bytes);

        //Assert the data_status signal and send the packed bytes
        foreach(bytes[i]) begin
          @(posedge input_intf.clk);
          input_intf.cb.data_status <= 1;
          input_intf.cb.data <= bytes[i];
        end

        //Deassert the data_status singal
        @(posedge input_intf.clk);
        input_intf.cb.data_status <= 0;
        input_intf.cb.data <= 0;

        //Push the packet in to mailbox for scoreboard
        driver2sb.put(pkt);

        $display("%0d : Driver : Finished Driving the packet",$time);
      end

      else begin
        $display ("%0d : Driver : **Randomization failed**",$time);
        //Increment the error count if randomization fails
        error++;
      end
    end
  endtask : start
  
endclass //Driver
  
//Receiver class
class Receiver;
  virtual OUTPUT_INTF.OP output_intf;
  mailbox receiver2sb;
  
  //Constructor
  function new(virtual OUTPUT_INTF.OP output_intf_new, mailbox receiver2sb);
   this.output_intf = output_intf_new  ;
   if(receiver2sb == null) begin
     $display("**ERROR**: receiver2sb is null");
     $finish;
   end
   else
     this.receiver2sb = receiver2sb;
  endfunction : new
  
  //Start method
  task start();
    logic [7:0] bytes[];
    Packet pkt;
    
    forever begin
      repeat(2) @(posedge output_intf.clk);
      wait(output_intf.cb.ready)
      output_intf.cb.read <= 1;
      
      repeat(2) @(posedge output_intf.clk);
      while (output_intf.cb.ready) begin
        bytes = new[bytes.size](bytes);
        bytes[bytes.size - 1] = output_intf.cb.port;
        @(posedge output_intf.clk);
      end
      
      output_intf.cb.read <= 0;
      
      @(posedge output_intf.clk);
      $display("%0d : Receiver : Received a packet",$time);
      
      pkt = new();
      pkt.byte_unpack(bytes);
      pkt.display();
      receiver2sb.put(pkt);
      bytes.delete();
    end
  endtask : start
    
endclass //Receiver

//Coverage class
class Coverage;
  Packet pkt;
  
  covergroup switch_coverage;
    length: coverpoint pkt.length;
    da: coverpoint pkt.da {
      bins p0 = {`P0};
      bins p1 = {`P1};
      bins p2 = {`P2};
      bins p3 = {`P3};}
    length_kind: coverpoint pkt.length_kind;
    
    all_cross: cross length, da, length_kind;
  endgroup
  
  function new();
    switch_coverage = new();
  endfunction : new
  
  task sample(Packet pkt);
    this.pkt = pkt;
    
    switch_coverage.sample();
  endtask : sample
  
endclass //Coverage

//Scoreboard class
class Scoreboard;
  mailbox driver2sb;
  mailbox receiver2sb;
  Coverage cov = new();
  
  //Constructor
  function new(mailbox driver2sb,mailbox receiver2sb);
    this.driver2sb = driver2sb;
    this.receiver2sb = receiver2sb;
  endfunction : new
  
  //Start method
  task start();
    Packet pkt_rcv, pkt_exp;      //Packet received and Packet expected
    forever begin
      receiver2sb.get(pkt_rcv);
      $display("%0d : Scorebooard : Scoreboard received a packet",$time);
      driver2sb.get(pkt_exp);
      if(pkt_rcv.compare(pkt_exp)) begin
        $display("%0d : Scoreboardd : Packet Matched ",$time);
        cov.sample(pkt_exp);
      end
      else
        error++;
    end
  endtask : start

endclass //Scoreboard

//Environment class
class Environment;
  virtual MEM_INTF.MEM mem_intf;
  virtual INPUT_INTF.IP input_intf;
  virtual OUTPUT_INTF.OP output_intf[4];
  
  Driver driver;
  Receiver receiver[4];
  Scoreboard sb;
  mailbox driver2sb;
  mailbox receiver2sb;
  
  //Constructor
  function new(
    virtual MEM_INTF.MEM mem_intf_new,
    virtual INPUT_INTF.IP input_intf_new,
    virtual OUTPUT_INTF.OP output_intf_new[4] );

  this.mem_intf = mem_intf_new;
  this.input_intf = input_intf_new;
  this.output_intf = output_intf_new;

    $display("%0d : Environemnt : Created env object", $time);
  endfunction : new
  
  //Build method
  function void build();
    $display("%0d : Environemnt : Start of build() method",$time);
    driver2sb = new();
    receiver2sb = new();
    sb = new(driver2sb, receiver2sb);
    driver= new(input_intf, driver2sb);
    foreach(receiver[i])
      receiver[i] = new(output_intf[i], receiver2sb);
    $display("%0d : Environemnt : end of build() method",$time);
  endfunction : build
  
  //Reset method
  task reset();
    $display("%0d : Environemnt : start of reset() method",$time);
    
    // Drive all DUT inputs to a known state
    mem_intf.cb.mem_data <= 8'h00;
    mem_intf.cb.mem_addr <= 2'b0;
    mem_intf.cb.mem_en <= 1'b0;
    mem_intf.cb.mem_rw <= 1'b0;
    input_intf.cb.data <= 8'h00;
    input_intf.cb.data_status <= 1'b0;
    output_intf[0].cb.read <= 1'b0;
    output_intf[1].cb.read <= 1'b0;
    output_intf[2].cb.read <= 1'b0;
    output_intf[3].cb.read <= 1'b0;

    // Reset the DUT
    input_intf.rst <= 1'b1;
    repeat(4) @ input_intf.clk;
    input_intf.rst <= 1'b0;

    $display("%0d : Environemnt : end of reset() method",$time);
  endtask : reset
  
  //Configure DUT method
  task cfg_dut();
    $display("%0d : Environemnt : start of cfg_dut() method",$time);

    mem_intf.cb.mem_en <= 1'b1;
    @(posedge mem_intf.clk);
    mem_intf.cb.mem_rw <= 1'b1;

    @(posedge mem_intf.clk);
    mem_intf.cb.mem_addr <= 2'b00;
    mem_intf.cb.mem_data <= `P0;
    $display("%0d : Environemnt : Port 0 Address %h ",$time,`P0);

    @(posedge mem_intf.clk);
    mem_intf.cb.mem_addr  <= 2'b01;
    mem_intf.cb.mem_data <= `P1;
    $display("%0d : Environemnt : Port 1 Address %h ",$time,`P1);

    @(posedge mem_intf.clk);
    mem_intf.cb.mem_addr <= 2'b10;
    mem_intf.cb.mem_data <= `P2;
    $display("%0d : Environemnt : Port 2 Address %h ",$time,`P2);

    @(posedge mem_intf.clk);
    mem_intf.cb.mem_addr <= 2'b11;
    mem_intf.cb.mem_data <= `P3;
    $display("%0d : Environemnt : Port 3 Address %h ",$time,`P3);

    @(posedge mem_intf.clk);
    mem_intf.cb.mem_en <= 1'b0;
    mem_intf.cb.mem_rw <= 1'b0;
    mem_intf.cb.mem_addr <= 2'b0;
    mem_intf.cb.mem_data <= 8'h00;

    $display("%0d : Environemnt : end of cfg_dut() method",$time);
  
  endtask :cfg_dut
  
  //Start method
  task start();
    $display("%0d : Environemnt : start of start() method",$time);
    fork
      driver.start();
      receiver[0].start();
      receiver[1].start();
      receiver[2].start();
      receiver[3].start();
      sb.start();
    join_any
    $display("%0d : Environemnt : end of start() method",$time);
  endtask : start
  
  //Wait for end method
  task wait_for_end();
    $display("%0d : Environemnt : start of wait_for_end() method",$time);
    repeat(10000) @(input_intf.clk);
    $display("%0d : Environemnt : end of wait_for_end() method",$time);
  endtask : wait_for_end
  
  //Report method
  task report();
    $display("\n\n*************************************************");
    
    if(error == 0)
      $display("********            TEST PASSED         *********");
    else
      $display("********    TEST Failed with %d errors *********", error);

    $display("*************************************************\n\n");
  endtask:report

  
endclass //Environment

//TESTCASE
program testcase(
  MEM_INTF.MEM mem_intf,
  INPUT_INTF.IP input_intf,
  OUTPUT_INTF.OP output_intf[4]);

  Environment env;
  Packet pkt;

  initial begin
    $display("******************* Start of testcase ****************");
    pkt = new();
    env = new(mem_intf,input_intf,output_intf);
    env.build();
    env.driver.gpkt = pkt;
    env.reset();
    env.cfg_dut();
    env.start();
    env.wait_for_end();
    env.report();

    #1000;
  end

  final
    $display("******************** End of testcase *****************");

endprogram //TESTCASE

//Top module
module top();
  bit clk;
  
  initial begin
    clk = 1'b0;
    forever #10 clk = ~clk;
  end
  
  MEM_INTF mem_intf(clk);
  INPUT_INTF input_intf(clk);
  OUTPUT_INTF output_intf[4](clk);
  
  testcase TC(mem_intf, input_intf, output_intf);
  
  switch DUT(
    .clk(clk),
    .rst(input_intf.rst),
    .data_status(input_intf.data_status),
    .data(input_intf.data),
    .port0(output_intf[0].port),
    .port1(output_intf[1].port),
    .port2(output_intf[2].port),
    .port3(output_intf[3].port),
    .ready0(output_intf[0].ready),
    .ready1(output_intf[1].ready),
    .ready2(output_intf[2].ready),
    .ready3(output_intf[3].ready),
    .read0(output_intf[0].read),
    .read1(output_intf[1].read),
    .read2(output_intf[2].read),
    .read3(output_intf[3].read),
    .mem_en(mem_intf.mem_en),
    .mem_rw(mem_intf.mem_rw),
    .mem_addr(mem_intf.mem_addr),
    .mem_data(mem_intf.mem_data));

endmodule //switch