`timescale 1ns/10ps

`include "uart_tx.v"
`include "uart_rx.v"

module uart_tb();

    parameter CLK_PERIOD    = 100;
    parameter CLKS_PER_BIT  = 51;
    //parameter BIT_PERIOD    = 5000;
    
    reg tb_clk          = 1'b0;
    reg [7:0] test_data = 8'hAB;
    wire tx_serial;
    wire rx_serial;
    wire [7:0] rx_byte;
    
    assign rx_serial = tx_serial;
    
    always #(CLK_PERIOD/2) tb_clk <= ~tb_clk;
    
    uart_tx #(.CLKS_PER_BIT(CLKS_PER_BIT)) uart_tx_inst (
    .tx_serial(tx_serial),
    .tx_clk(tb_clk),
    .tx_data_in(test_data)
    );
    
    uart_rx #(.CLKS_PER_BIT(CLKS_PER_BIT)) uart_rx_inst (
    .rx_data_out(rx_byte),
    .rx_serial(rx_serial),
    .rx_clk(tb_clk)
    );
    

endmodule