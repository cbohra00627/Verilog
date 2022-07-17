`timescale 1ns / 1ps

module I2C_TB();
    reg clk;
    reg reset;
    
    wire sda;
    wire scl;
    wire clk_i;
    wire [6:0] addr_s;
    wire [7:0] data_wr;
    wire [7:0] data_rd;
    wire busy;
    wire error;
    
    reg enable;
    reg rw;
    reg [6:0] ADDR_M;
    reg [6:0] ADDR_S;
    
    CLK_DIVIDER #(.DELAY(1000)) DIVIDER(
        .RESET(reset),
        .REF_CLK(clk),
        .I2C_CLK(clk_i));
    
    I2C_MASTER MASTER(
        .CLK(clk_i),
        .RESET(reset),
        .ENABLE(enable),
        .RW(rw),
        .S_ADDR(ADDR_M),
        .DATA_WR(8'hAC),
        .DATA_RD(data_rd),
        .SDA(sda),
        .SCL(scl),
        .ERROR(error),
        .BUSY(busy));
        
    I2C_SLAVE SLAVE(
        .CLK(clk_i),
        .SDA(sda),
        .SCL(scl),
        .S_ADDR(ADDR_S),
        .ADDR(addr_s),
        .DATA_WR(data_wr),
        .DATA_RD(8'h28));
        
    initial begin
        clk = 0;
        
        forever begin
            clk = #5 ~clk;
        end
    end
    
    initial begin
        
        enable = 0;
        reset = 1;
        ADDR_S = 7'h5E;
        
        
        //Write byte = 8'h47
        #5000;
        reset = 0;
        rw = 1;
        ADDR_M = ADDR_S;
        
        #20000;
        enable = 1;
        
        #100;
        while (busy != 0) begin
            #1000;
        end
        enable = 0;
        
        
        //Write byte = 8'hFB
        #50000
        reset = 0;
        rw = 0;
        ADDR_M = ADDR_S;
        
        #15000;
        enable = 1;
        
        #100;
        while (busy != 0) begin
            #1000;
        end
        enable = 0;
            
        $finish;
    end
endmodule