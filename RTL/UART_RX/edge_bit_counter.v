module Edge_Bit_Counter  (

input wire       Edge_EN_CNT,
input wire       Bit_EN_CNT,
input wire [5:0] prescaler,
input wire       CLK,RST,

output reg [2:0] Bit_Counter,
output reg [4:0] Edge_Counter,
output wire      Done
);

always @(posedge CLK or negedge RST)
begin
     if(!RST)
        begin
             Edge_Counter <='b0;
        end
     else if (Edge_EN_CNT)
        begin
            if (Done)
               begin
                 Edge_Counter<='b0;
               end
            else
               begin
                 Edge_Counter<=Edge_Counter +1'b1;
               end
        end
end

always @(posedge CLK or negedge RST)
begin
     if(!RST)
        begin
             Bit_Counter <='b0;
        end

     else if (Bit_EN_CNT && Done && Edge_EN_CNT)
        begin
                 Bit_Counter<=Bit_Counter +1'b1;
        end
     else if (~Bit_EN_CNT)
        begin
                 Bit_Counter<=1'b0;
        end
end

assign Done = (Edge_Counter==(prescaler - 1));

endmodule 
