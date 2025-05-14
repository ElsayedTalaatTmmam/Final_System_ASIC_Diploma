module parity_check #(parameter Data_Width=8)(

input wire      	     Sampled_bit,
input wire                   Parity_EN,
input wire                   Parity_TYP,
input wire  [Data_Width-1:0] P_DATA_par,
input wire                   CLK,RST,

output reg      	     Parity_ERR
);

localparam  EVEN =1'b0;
localparam  ODD  =1'b1;

always @(posedge CLK or negedge RST)
begin
      if(!RST)
        begin
             Parity_ERR <='b0;
        end

      else if (Parity_EN)
        begin
           case(Parity_TYP)

	     EVEN : begin                 
                     if(Sampled_bit ==^P_DATA_par)
                      begin
                       Parity_ERR <='b0;
                      end
                     else
                      begin
                       Parity_ERR <='b1;
                      end
                    end

	      ODD : begin
                     if(Sampled_bit ==~^P_DATA_par)
                      begin
                       Parity_ERR <='b0;
                      end
                     else
                      begin
                       Parity_ERR <='b1;
                      end	
                    end
	  endcase       	
       end

       end

endmodule 
