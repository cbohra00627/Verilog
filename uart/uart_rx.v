module uart_rx
    #(parameter CLKS_PER_BIT = 87)
    (output [7:0] rx_data_out,          //Data to be sent to the computer
    input rx_serial,                        //Serial data being received bit by bit
    input rx_clk                            //Clock Input
    );
    
    //Parameters for State Machine to be used to change conditions (or states) the case statement
    parameter RX_IDLE       = 3'b000;
    parameter RX_START_BIT  = 3'b001;
    parameter RX_DATA_BIT   = 3'b010;
    parameter RX_STOP_BIT   = 3'b011;
    parameter RX_CLEANUP    = 3'b100;
    
    reg rx_bit          = 1'b1;             //This stores the data bits from the serial communication to remove metastability
    reg rx_data         = 1'b1;             //This contains the data bits which will be used to transfer data to the receiver computer
    
    reg [7:0] rx_byte       = 8'b0;         //Data byte stored by receiver before sending to the computer
    reg [7:0] clk_count     = 8'b0;         //Counts number of clock cycles passed
    reg [2:0] rx_state      = 3'b0;         //To be used to store states
    reg [2:0] rx_bit_index  = 3'b0;         //Index of the received bit
    
    always @(rx_clk) clk_count <= clk_count + 1'b1;
    
    always @(posedge rx_clk) begin
        rx_bit  <= rx_serial;
        rx_data <= rx_bit;
    end
    
    always @(posedge rx_clk) begin
        
        case(rx_state)
            //When the device is idle
            RX_IDLE:
            begin
                clk_count    <= 1'b0;
                rx_bit_index <= 1'b0;
                
                if (rx_data == 1'b0) begin          //Runs when start bit is received (transition from high to low)
                    rx_state <= RX_START_BIT;
                end
                else begin
                    rx_state <= RX_IDLE;
                end
            end
            
            //Check the middle of the start bit
            RX_START_BIT:
            begin
                if (clk_count < (CLKS_PER_BIT - 1'b1)/2) begin
                    rx_state  <= RX_START_BIT;
                end
                else begin
                    if (rx_data == 1'b0) begin
                        clk_count <= 8'b0;
                        rx_state  <= RX_DATA_BIT;
                    end
                    else begin
                        rx_state <= RX_IDLE;
                    end
                end
            end
            
            //Check the middle of the data bits and sample data
            RX_DATA_BIT:
            begin
                if (clk_count < CLKS_PER_BIT - 1) begin
                    rx_state    <= RX_DATA_BIT;
                end
                else begin
                    clk_count               <= 8'b0;
                    rx_byte[rx_bit_index]   <= rx_data;
                    
                    //Check if received all the bits
                    if (rx_bit_index < 3'b111) begin
                        rx_bit_index    <= rx_bit_index + 1'b1;
                        rx_state        <= RX_DATA_BIT;
                    end
                    else begin
                        rx_bit_index    <= 3'b0;
                        rx_state        <= RX_STOP_BIT;
                    end
                end
            end
            
            //Receive stop bit. Stop bit = 1'b1
            RX_STOP_BIT:
            begin
                if (clk_count < CLKS_PER_BIT - 1) begin
                    rx_state    <= RX_STOP_BIT;
                end
                else begin
                    if (rx_data == 1'b1) begin
                        clk_count   <= 8'b0;
                        rx_state    <= RX_CLEANUP;
                    end
                    else begin
                        clk_count   <= 3'b0;
                        rx_state    <= RX_CLEANUP;
                    end
                end
            end
            
            //Clean the state and stay here for 1 clock cycle
            RX_CLEANUP:
            begin
                rx_state    <= RX_IDLE;
            end
            
            //Default statement to stay in idle mode
            default:
                rx_state    <= RX_IDLE;
            
        endcase
        
    end
    
    assign rx_data_out  = rx_byte;
    
endmodule