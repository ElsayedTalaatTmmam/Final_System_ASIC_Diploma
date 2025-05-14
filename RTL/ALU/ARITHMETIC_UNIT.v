module ARITHMETIC_UNIT # ( parameter IN_DATA_WIDTH = 16 , OUT_DATA_WIDTH = IN_DATA_WIDTH+IN_DATA_WIDTH )(

input  wire signed [IN_DATA_WIDTH-1:0]  A , B,
input  wire        [1:0]                ALU_FUNC,
input  wire                             RST,CLK,
input  wire                             Arith_Enable,                       
output reg  signed [OUT_DATA_WIDTH-1:0] Arith_OUT,                      
output reg                              Carry_OUT,Arith_Flag
);

     /****** Internal Signal ******/
       reg  [OUT_DATA_WIDTH-1:0] ALU_Arith ;
       reg                       ALU_Carry;
       reg                       Arith_Flag_reg ;
     /****** Combinational Block ******/
always @ (*)
 begin 
  if ( Arith_Enable )
    begin
                 //Arith_Flag_reg = 1'b1;
     case( ALU_FUNC[1:0] )
      2'b00 : begin 
               {ALU_Carry, ALU_Arith } = A + B ;
                 Arith_Flag_reg = 1'b1;
              end 
      2'b01 : begin 
               {ALU_Carry, ALU_Arith } = A - B ;
                 Arith_Flag_reg = 1'b1; 
              end
      2'b10 : begin 
               {ALU_Carry, ALU_Arith } = A * B ;
		 Arith_Flag_reg = 1'b1; 
              end
      2'b11 : begin 
               {ALU_Carry, ALU_Arith } = A / B ;
		 Arith_Flag_reg = 1'b1;
	      end
     endcase 
    end
  else 
    begin
     ALU_Arith = 16'b0;
     ALU_Carry = 1'b0 ;
     Arith_Flag_reg= 1'b0 ;
    end 
 end 

     /****** Sequential Block ******/
     /******    Regesterd     ******/
always @ (posedge CLK , negedge RST )
 if (!RST)
  begin
   Arith_OUT <=16'b0;
   Carry_OUT <= 1'b0;
   Arith_Flag <= 1'b0 ;   
  end 
 else 
  begin
   Arith_OUT  <= ALU_Arith;
   Carry_OUT  <= ALU_Carry; 
   Arith_Flag <= Arith_Flag_reg ;
  end 
endmodule 