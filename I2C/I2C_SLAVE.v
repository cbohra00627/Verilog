`timescale 1ns / 1ps

module I2C_SLAVE(
    input CLK,                  //System clock
    inout SDA,                  //SDA line
    input SCL,                  //SCL line
    input [6:0] S_ADDR,         //Slave address
    input [7:0] DATA_RD,        //Data to be read
    
    output [6:0] ADDR,          //Address output (for monitoring purpose only)
    output [7:0] DATA_WR);      //Data to be written
    
    //States
    parameter S_START_S=4'b0000, S_ADDR_S=4'b0001, S_RW_S=4'b0010, S_ACK1_S=4'b0011;
    parameter S_BYTE_WR_S=4'b0100, S_BYTE_RD_S=4'b0101, S_ACK2_S=4'b0110, S_STOP_S=4'b0111;
    reg [3:0] STATE, NEXT;
    
    reg [3:0] cnt;
    reg [6:0] s_addr;
    reg [7:0] data_wr;
    reg [7:0] data_rd;
    reg rw;
    reg sda_ena;
    reg sda;
    
    always @(*) begin
        case (STATE)
            //Waiting for start bit (SDA = 0)
            S_START_S: begin
                sda_ena = 1'b0;
                
                NEXT = (SDA == 1'b0) ? S_ADDR_S : S_START_S;
            end
            
            //Waiting for address byte and storing it from another block
            S_ADDR_S: begin
                sda_ena = 1'b0;
                
                NEXT = (cnt == 4'b0111) ? S_RW_S : S_ADDR_S;
            end
            
            //Choosing between Read(0) or Write(1)
            S_RW_S: begin
                sda_ena = 1'b0;
                
                data_rd = (~rw) ? DATA_RD : 8'b0;
                NEXT = S_ACK1_S;
            end
            
            //Generating acknowledgement bit for slave address
            S_ACK1_S: begin
                if (s_addr == S_ADDR) begin
                    sda_ena = 1'b1;
                    sda = 1'b0;
                    NEXT = (rw) ? S_BYTE_WR_S : S_BYTE_RD_S;
                end
                else begin
                    sda_ena = 1'b0;
                    NEXT = S_STOP_S;
                end
            end
            
            //Waiting for data byte and writing to the slave from another block
            S_BYTE_WR_S: begin
                sda_ena = 1'b0;
                
                NEXT = (cnt == 4'b0111) ? S_ACK2_S : S_BYTE_WR_S;
            end
            
            //Reading data from slave
            S_BYTE_RD_S: begin
                sda = data_rd[4'b0111-cnt];
                sda_ena = 1'b1;
                
                NEXT = (cnt == 4'b0111) ? S_ACK2_S : S_BYTE_RD_S;
            end
            
            //Generating acknowledgement bit for data byte
            S_ACK2_S: begin
                sda_ena = 1'b1;
                sda = 1'b0;
                
                NEXT = S_STOP_S;
            end
            
            //Waiting for stop bit
            S_STOP_S: begin
                sda_ena = 1'b0;
                data_rd = 0;
                
                if ((SDA == 1'b1) && (SCL == 1'b1)) begin
                    NEXT = S_START_S;
                end
                else begin
                    NEXT = S_STOP_S;
                end
            end
            
            default: NEXT = S_START_S;
        endcase
    end
    
    always @(posedge SCL) begin
        case(STATE)
            S_START_S: begin
                rw <= 1'b0;
                s_addr <= 7'b0;
                data_wr <= 8'b0;
            end
            S_ADDR_S: s_addr[4'b0110-cnt+1'b1] <= SDA;
            S_RW_S: rw <= SDA;
            S_ACK1_S: ;
            S_BYTE_WR_S: data_wr[4'b0111-cnt] <= SDA;
            S_BYTE_RD_S: ;
            S_ACK2_S: ;
            S_STOP_S: begin
                rw <= 1'b0;
                s_addr <= 7'b0;
                data_wr <= 8'b0;
            end
            default: begin
                rw <= 1'b0;
                s_addr <= 7'b0;
                data_wr <= 8'b0;
            end
        endcase
    end
    
    //Update counter
    always @(negedge SCL) begin
        if ((STATE == S_ADDR_S) || (STATE == S_BYTE_WR_S) || (STATE == S_BYTE_RD_S))
            cnt <= cnt + 1'b1;
        else
            cnt <= 4'b0;
    end
    
    //State transition
    always @(posedge CLK) begin
        STATE <= NEXT;
    end
    
    assign ADDR = s_addr;
    assign DATA_WR = data_wr;
    assign SDA = (sda_ena) ? sda : 1'bz;
    
endmodule