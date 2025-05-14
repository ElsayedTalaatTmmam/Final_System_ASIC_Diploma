module SYS_CTRL #(
    parameter DATA_WIDTH = 8,
    parameter RF_ADDR    =4
) (
    input wire CLK,
    input wire RST,
    input wire [ DATA_WIDTH - 1 : 0 ] RF_RdData,
    input wire RF_RdData_VLD,

    output reg RF_WrEn,
    output reg RF_RdEn,
    output reg [ RF_ADDR - 1 : 0 ] RF_Address,
    output reg [ DATA_WIDTH - 1 : 0 ] RF_WrData,

    output reg ALU_EN,
    output reg [ 3 : 0 ] ALU_FUN,
    input wire [ (2 * DATA_WIDTH) - 1 : 0 ] ALU_OUT,
    input wire ALU_OUT_VLD,


    output reg CLKG_EN,
    output reg CLKDIV_EN,
    input wire FIFO_FULL,

    input wire [ DATA_WIDTH - 1 : 0 ] UART_RX_DATA,
    input wire UART_RX_VLD,
    output reg [ DATA_WIDTH - 1 : 0 ] UART_TX_DATA,
    output reg UART_TX_VLD
);


reg [ 3 : 0 ] current_state , next_state ;

localparam [ 3 : 0 ]            IDLE_s                 = 4'b0000,
                                RF_Wr_ADDR_s           = 4'b0001,
                                RF_Wr_DATA_s           = 4'b0011,
                                RF_Rd_ADDR_s           = 4'b0010,
                                ALU_OP_A_s             = 4'b0110,
                                ALU_OP_B_s             = 4'b0111,
                                ALU_FUN_s              = 4'b0101,
                                ALU_FUN_NOP_s          = 4'b0100,
                                        
                                RF_VALID_Wait_s        = 4'b1100,
                                ALU_VALID_Wait_s       = 4'b1101,
                                    
                                FIFO_Write_RF_s        = 4'b1111,
                                FIFO_Write_ALU_BYTE1_s = 4'b1110,
                                FIFO_Write_ALU_BYTE2_s = 4'b1010;


localparam  [7:0]               RF_Wr_CMD   = 8'hAA ,
                                RF_Rd_CMD   = 8'hBB ,
					            ALU_OP_CMD  = 8'hCC ,
					            ALU_NOP_CMD = 8'hDD ;

reg [ DATA_WIDTH - 1 : 0 ] RF_ADDR_REG;
reg [ (2 * DATA_WIDTH) - 1 : 0 ] ALU_OUT_REG;

reg RF_ADDR_en, ALU_OUT_en;

//State Transition
always @(posedge CLK or negedge RST ) begin
    if( !RST ) begin
        current_state <= IDLE_s;
    end
    else begin
        current_state <= next_state;
    end
end

//Next State Logic
always @(*) begin
    case (current_state)


        IDLE_s: begin
            if(UART_RX_VLD)begin
                case (UART_RX_DATA)
                    RF_Wr_CMD: begin
                        next_state = RF_Wr_ADDR_s;
                    end

                    RF_Rd_CMD: begin
                        next_state = RF_Rd_ADDR_s;
                    end

                    ALU_OP_CMD: begin
                        next_state = ALU_OP_A_s;
                    end

                    ALU_NOP_CMD: begin
                        next_state = ALU_FUN_NOP_s;
                    end
                    default: 
                        next_state = IDLE_s;
                endcase
            end

            else begin
                next_state = IDLE_s;
            end
        end


        RF_Wr_ADDR_s: begin
            if( UART_RX_VLD ) begin
                next_state = RF_Wr_DATA_s;
            end
            else begin 
                next_state = RF_Wr_ADDR_s;
            end
        end

        RF_Wr_DATA_s: begin
            if( UART_RX_VLD ) begin
                next_state = IDLE_s;
            end
            else begin 
                next_state = RF_Wr_DATA_s;
            end
        end


        RF_Rd_ADDR_s: begin
            if( UART_RX_VLD ) begin
                next_state = FIFO_Write_RF_s;
            end
            else begin
                next_state = RF_Rd_ADDR_s;
            end
        end

        FIFO_Write_RF_s: begin
            if( RF_RdData_VLD ) begin
                next_state = IDLE_s;
            end
            else begin
                next_state = FIFO_Write_RF_s;
            end
        end

        ALU_OP_A_s: begin
            if( UART_RX_VLD ) begin
                next_state = ALU_OP_B_s;
            end
            else begin
                next_state = ALU_OP_A_s;
            end
        end

        ALU_OP_B_s: begin
            if( UART_RX_VLD ) begin
                next_state = ALU_FUN_s;
            end
            else begin
                next_state = ALU_OP_B_s;
            end
        end

        ALU_FUN_s: begin
            if( UART_RX_VLD ) begin
                next_state = ALU_VALID_Wait_s;
            end
            else begin
                next_state = ALU_FUN_s;
            end
        end

        ALU_VALID_Wait_s: begin
            if( ALU_OUT_VLD ) begin
                next_state = FIFO_Write_ALU_BYTE1_s;
            end
            else begin
                next_state = ALU_VALID_Wait_s;
            end
        end


       FIFO_Write_ALU_BYTE1_s: begin
                next_state = FIFO_Write_ALU_BYTE2_s;
       end  

       FIFO_Write_ALU_BYTE2_s: begin
                next_state = IDLE_s;
       end

        ALU_FUN_NOP_s: begin
            if( UART_RX_VLD ) begin
                next_state = ALU_VALID_Wait_s;
            end
            else begin
                next_state = ALU_FUN_NOP_s;
            end
        end

        default: 
            next_state = IDLE_s;
    endcase
end





//Output Calculations Logic
always @(*) begin

        RF_WrEn      = 1'b0;
        RF_RdEn      = 1'b0;
        RF_Address   = 'b0;
        RF_WrData    = 'b0;
  
        ALU_FUN      =  'b0;
        ALU_EN       = 1'b0;
  
        CLKG_EN      = 1'b0; 
        CLKDIV_EN    = 1'b1;
        UART_TX_DATA = 'b0;
        UART_TX_VLD  = 1'b0;

        ALU_OUT_en   = 1'b0;
        RF_ADDR_en   = 1'b0;  

    case (current_state)
        IDLE_s: begin
            ALU_EN     = 1'b0 ;
            ALU_FUN    = 4'b0 ;  
            CLKG_EN    = 1'b0 ; 
            CLKDIV_EN  = 1'b1 ;
            RF_WrEn    = 1'b0 ;
            RF_RdEn    = 1'b0 ;
            RF_Address =  'b0 ;
            RF_WrData  =  'b0 ;
        end


        RF_Wr_ADDR_s: begin
            if( UART_RX_VLD ) begin
                RF_ADDR_en = 1'b1;                
            end
            else begin 
                RF_ADDR_en = 1'b0;                
            end
        end

        RF_Wr_DATA_s: begin
            if( UART_RX_VLD ) begin
                RF_WrEn = 1'b1;
                RF_Address = RF_ADDR_REG [ RF_ADDR - 1 : 0 ];
                RF_WrData = UART_RX_DATA;
            end
            else begin 
                RF_WrEn = 1'b0;
                RF_Address = RF_ADDR_REG [ RF_ADDR - 1 : 0 ];
                RF_WrData = UART_RX_DATA;
            end
        end


        RF_Rd_ADDR_s: begin
            if( UART_RX_VLD ) begin
                RF_RdEn = 1'b1;
                RF_Address = UART_RX_DATA [ RF_ADDR - 1 : 0 ];
            end
            else begin
                RF_RdEn = 1'b0;
            end
        end

        FIFO_Write_RF_s: begin
            if( !FIFO_FULL && RF_RdData_VLD ) begin
                UART_TX_VLD = 1'b1;    
                UART_TX_DATA = RF_RdData;        
        end
            else begin
                UART_TX_VLD = 1'b0;            
            end
        end

        ALU_OP_A_s: begin
            if( UART_RX_VLD ) begin
                RF_WrEn    = 1'b1;
                RF_Address = 'd5;
                RF_WrData  = UART_RX_DATA;
            end
            else begin
                RF_WrEn    = 1'b0;
                RF_Address = 'd5;
                RF_WrData  = UART_RX_DATA;
            end
        end

        ALU_OP_B_s: begin
            if( UART_RX_VLD ) begin
                RF_WrEn    = 1'b1;
                RF_Address = 'd6;
                RF_WrData  = UART_RX_DATA;
            end
            else begin
                RF_WrEn    = 1'b0;
                RF_Address = 'd6;
                RF_WrData  = UART_RX_DATA;
            end
        end

        ALU_FUN_s: begin
            CLKG_EN = 1;
            if( UART_RX_VLD ) begin
                ALU_EN = 1;
                ALU_FUN = UART_RX_DATA [ 3:0 ];
            end
            else begin
                ALU_EN = 0;
                ALU_FUN = UART_RX_DATA [ 3:0 ];
            end
        end

        ALU_VALID_Wait_s: begin
            CLKG_EN = 1;
            if( ALU_OUT_VLD ) begin
                ALU_OUT_en = 1;
            end
            else begin
                ALU_OUT_en = 0;
            end
        end

       FIFO_Write_ALU_BYTE1_s: begin
            CLKG_EN = 1;
            if( !FIFO_FULL ) begin
                UART_TX_VLD = 1'b1;
                UART_TX_DATA = ALU_OUT_REG [ DATA_WIDTH - 1 : 0 ];
            end
            else begin
                UART_TX_VLD = 1'b0;
                UART_TX_DATA = ALU_OUT_REG [ DATA_WIDTH - 1 : 0 ];
            end
       end  

       FIFO_Write_ALU_BYTE2_s: begin
            CLKG_EN = 1;
            if( !FIFO_FULL ) begin
                UART_TX_VLD = 1'b1;
                UART_TX_DATA = ALU_OUT_REG [ (2*DATA_WIDTH) - 1 : DATA_WIDTH ];
            end
            else begin
                UART_TX_VLD = 1'b0;
                UART_TX_DATA = ALU_OUT_REG [ (2*DATA_WIDTH) - 1 : DATA_WIDTH ];
            end
       end

        ALU_FUN_NOP_s: begin
            CLKG_EN = 1;
            if( UART_RX_VLD ) begin
                ALU_EN = 1;
                ALU_FUN = UART_RX_DATA [ 3:0 ];
            end
            else begin
                ALU_EN = 0;
                ALU_FUN = UART_RX_DATA [ 3:0 ];
            end
        end

        default: 
            begin
                ALU_EN     = 1'b0 ;
                ALU_FUN    = 4'b0 ;  
                CLKG_EN    = 1'b0 ; 
                CLKDIV_EN  = 1'b1 ;
                RF_WrEn    = 1'b0 ;
                RF_RdEn    = 1'b0 ;
                RF_Address =  'b0 ;
                RF_WrData  =  'b0 ; 
            end


    endcase
end


/// RF_ADDRESS
always @(posedge CLK or negedge RST ) begin
    if( !RST ) begin
        RF_ADDR_REG <= 0;
    end
    else begin
        if( RF_ADDR_en )
            RF_ADDR_REG <= UART_RX_DATA;
    end
end


always @(posedge CLK or negedge RST ) begin
    if( !RST ) begin
        ALU_OUT_REG <= 0;
    end
    else begin
        if( ALU_OUT_en )
            ALU_OUT_REG <= ALU_OUT;
    end
end




endmodule
