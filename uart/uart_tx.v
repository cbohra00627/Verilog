module uart_tx
    #(parameter CLKS_PER_BIT = 87)
    (output tx_serial,
    input tx_clk,
    input [7:0] tx_data_in
    );
    
    parameter TX_IDLE           = 3'b000;
    parameter TX_START_BIT      = 3'b001;
    parameter TX_DATA_BIT       = 3'b010;
    parameter TX_STOP_BIT       = 3'b011;
    parameter TX_CLEANUP        = 3'b100;
    
    reg [7:0] tx_byte       = 8'b0;         //Data byte stored, waiting to be converted into serial data
    reg [7:0] clk_count     = 8'b0;         //Counts number of clock cycles passed
    reg [2:0] tx_state      = 3'b0;         //To be used to store states
    reg [2:0] tx_bit_index  = 3'b0;         //Index of the bit being transmitted
    reg tx_serial           = 1'b1;         //Used to transfer data bits over serial communication
    
    always @(tx_clk) clk_count <= clk_count + 1'b1;
    
    always @(posedge tx_clk) begin
    
        case (tx_state)
        //When the device is idle
        TX_IDLE:
        begin
            tx_serial       <= 1'b1;        //High for idle state
            clk_count       <= 8'b0;
            tx_bit_index    <= 3'b0;
            
            tx_byte     <= tx_data_in;
            tx_state    <= TX_START_BIT;
        end
        
        //Send the start bit
        TX_START_BIT:
        begin
            tx_serial   <= 1'b0;
            
            //Wait CLKS_PER_BIT-1 clock cycles for start bit to finish
            if (clk_count < CLKS_PER_BIT - 1'b1) begin
                tx_state    <= TX_START_BIT;
            end
            else begin
                clk_count   <= 8'b0;
                tx_state    <= TX_DATA_BIT;
            end
        end
        
        //Send the data bits
        TX_DATA_BIT:
        begin
            tx_serial   <= tx_byte[tx_bit_index];
            
            //Wait CLKS_PER_BIT-1 clock cycles to send data bits
            if (clk_count < CLKS_PER_BIT - 1'b1) begin
                tx_state    <= TX_DATA_BIT;
            end
            else begin
                clk_count   <= 0;
                
                //Check if all the bits have been sent or not
                if (tx_bit_index < 3'b111) begin
                    tx_bit_index    <= tx_bit_index + 1'b1;
                    tx_state        <= TX_DATA_BIT;
                end
                else begin
                    tx_bit_index    <= 3'b0;
                    tx_state        <= TX_STOP_BIT;
                end
            end
        end
        
        //Send the stop bit. Stop bit = 1
        TX_STOP_BIT:
        begin
            tx_serial   <= 1'b1;
            
            //Wait for CLKS_PER_BIT-1 clock cycles for stop bit to finish
            if (clk_count < CLKS_PER_BIT - 1'b1) begin
                tx_state    <= TX_STOP_BIT;
            end
            else begin
                clk_count   <= 8'b0;
                tx_state    <= TX_CLEANUP;
            end
        end
        
        //Clean the state and stay here for one clock cycle
        TX_CLEANUP:
        begin
            tx_state    <= TX_IDLE;
        end
        
        //Default statement
        default:
            tx_state    <= TX_IDLE;
        endcase
    
    end
    
endmodule