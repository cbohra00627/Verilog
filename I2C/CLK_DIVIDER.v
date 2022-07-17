module CLK_DIVIDER(
    input RESET,
    input REF_CLK,
    output I2C_CLK);
    
    parameter DELAY = 1000;
    
    reg [9:0] cnt;
    reg i2c_clk;
    
    always @(posedge REF_CLK) begin
        if (RESET) begin
            i2c_clk = 1'b0;
            cnt = 10'b0;
        end
        else begin
            if (cnt == ((DELAY/2)-1)) begin
                i2c_clk = ~i2c_clk;
                cnt = 10'b0;
            end
            else
                cnt = cnt + 1'b1;
        end
    end
    
    assign I2C_CLK = i2c_clk;

endmodule