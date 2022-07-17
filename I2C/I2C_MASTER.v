`timescale 1ns / 1ps

module I2C_MASTER(
    input CLK,                  //System clock
    input RESET,                //Reset
    input ENABLE,               //Enable the Master
    input RW,                   //Read(0) or Write(1)
    
    input [6:0] S_ADDR,         //Slave Address
    input [7:0] DATA_WR,        //Data to be written to the slave
    output [7:0] DATA_RD,       //Data to be read from the slave
    
    output ERROR,               //Error(1) if acknowledgement bit is not low
    output BUSY,                //Busy(1) if Master is transmitting the message
    
    inout SDA,                  //SDA Line
    output SCL);                //SCL Line
    
    //States
    parameter S_IDLE_M=4'b0000, S_START_M=4'b0001, S_ADDR_M=4'b0010, S_RW_M=4'b0011, S_ACK1_M=4'b0100;
    parameter S_BYTE_WR_M=4'b0101, S_BYTE_RD_M=4'b0110, S_ACK2_M=4'b0111, S_STOP_M=4'b1000;
    reg [3:0] STATE, NEXT;
    
    reg sda;
    wire scl;
    reg scl_ena;
    reg sda_ena;
    
    reg error;
    reg busy;
    
    reg [3:0] cnt;          //Bit Counter
    reg [6:0] s_addr;       //Slave Address
    reg [7:0] data_wr;      //Data to be written
    reg [7:0] data_rd;      //Data to be read
    
    always @(*) begin
        case(STATE)
            //IDLE State waits for ENABLE to be set
            S_IDLE_M: begin
                sda = 1'b1;
                scl_ena = 1'b0;
                sda_ena = 1'b1;
                
                busy = (ENABLE) ? 1'b1 : 1'b0;
                NEXT = (ENABLE) ? S_START_M : S_IDLE_M;
            end
            
            //Generate Start condition
            S_START_M: begin
                sda = 1'b0;
                scl_ena = 1'b0;
                sda_ena = 1'b1;
                busy = 1'b1;
                
                s_addr = S_ADDR;
                data_wr = DATA_WR;
                
                NEXT = S_ADDR_M;
            end
            
            //Send Slave Address over SDA
            S_ADDR_M: begin
                sda = s_addr[4'b0110-cnt];
                scl_ena = 1'b1;
                sda_ena = 1'b1;
                busy = 1'b1;
                
                NEXT = (cnt == 4'b0110) ? S_RW_M : S_ADDR_M;
            end
            
            //Send Read(0)/Write(1) bit over SDA
            S_RW_M: begin
                sda = RW;
                scl_ena = 1'b1;
                sda_ena = 1'b1;
                busy = 1'b1;
                
                NEXT = S_ACK1_M;
            end
            
            //Wait for acknowledgement for address from slave
            S_ACK1_M: begin
                scl_ena = 1'b1;
                sda_ena = 1'b0;
                busy = 1'b1;
                
                if (~error)
                    NEXT = (RW) ? S_BYTE_WR_M : S_BYTE_RD_M;
                else
                    NEXT = S_IDLE_M;
            end
            
            //Send data byte to the slave over SDA
            S_BYTE_WR_M: begin
                sda = data_wr[4'b0111-cnt];
                scl_ena = 1'b1;
                sda_ena = 1'b1;
                busy = 1'b1;
                
                NEXT = (cnt == 4'b0111) ? S_ACK2_M : S_BYTE_WR_M;
            end
            
            //Read data byte from the slave
            S_BYTE_RD_M: begin
                scl_ena = 1'b1;
                sda_ena = 1'b0;
                
                NEXT = (cnt == 4'b0111) ? S_ACK2_M : S_BYTE_RD_M;
            end
            
            //Wait for acknowledgement for data byte from slave
            S_ACK2_M: begin
                scl_ena = 1'b1;
                sda_ena = 1'b0;
                busy = 1'b1;
                
                if (~error)
                    NEXT = S_STOP_M;
                else
                    NEXT = S_IDLE_M;
            end
            
            //Generate stop condition
            S_STOP_M: begin
                scl_ena = 1'b1;
                sda_ena = 1'b1;
                sda = 0;
                busy = 1'b0;
                
                NEXT = S_IDLE_M;
            end
            
            default: NEXT = S_IDLE_M;
        endcase
    end
    
    //Control the error signal
    always @(negedge CLK) begin
        case(STATE)
            S_START_M: error <= 0;
            S_ADDR_M: error <= 0;
            S_RW_M: error <= 0;
            S_ACK1_M: error <= (SDA) ? 1'b1 : 1'b0;
            S_BYTE_WR_M: error <= 0;
            S_BYTE_RD_M: error <= 0;
            S_ACK2_M: error <= (SDA) ? 1'b1 : 1'b0;
            S_STOP_M: error <= 0;
            default: error <= 0;
        endcase
    end
    
    //Read data from slave
    always @(posedge SCL) begin
        case(STATE)
            S_START_M: data_rd <= 0;
            S_ADDR_M: data_rd <= 0;
            S_RW_M: data_rd <= 0;
            S_ACK1_M: data_rd <= 0;
            S_BYTE_WR_M: data_rd <= 0;
            S_BYTE_RD_M: data_rd[4'b0111-cnt] <= SDA;
            S_ACK2_M: data_rd <= data_rd;
            S_STOP_M: data_rd <= 0;
            default: data_rd <= 0;
        endcase
    end
    
    //Update counter
    always @(posedge scl) begin
        if (RESET)
            cnt <= 4'b0;
        else if ((STATE == S_ADDR_M) || (STATE == S_BYTE_WR_M) || (STATE == S_BYTE_RD_M))
            cnt <= cnt + 1'b1;
        else
            cnt <= 4'b0;
    end
    
    //State Transition with reset
    always @(posedge scl) begin
        if (RESET)
            STATE <= S_IDLE_M;
        else
            STATE <= NEXT;
    end
    
    assign SDA = (sda_ena) ? sda : 1'bz;
    assign scl = CLK;
    assign SCL = (scl_ena) ? ~scl : 1'b1;
    assign DATA_RD = data_rd;
    assign ERROR = error;
    assign BUSY = busy;

endmodule