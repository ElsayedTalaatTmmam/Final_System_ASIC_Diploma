module LOGIC_UNIT # ( parameter IN_DATA_WIDTH = 16 , OUT_DATA_WIDTH = 16 )(

input  wire signed [IN_DATA_WIDTH-1:0]  A , B,
input  wire        [1:0]                ALU_FUNC,
input  wire                             RST,CLK,
input  wire                             Logic_Enable,                       
output reg        [OUT_DATA_WIDTH-1:0]  Logic_OUT,                      
output reg                              Logic_Flag
);

     /****** Internal Signal ******/
       reg  [OUT_DATA_WIDTH-1:0] ALU_Logic ;
       reg                       Logic_Flag_reg ;
     /****** Combinational Block ******/
always @ (*)
 begin 
  if ( Logic_Enable )
    begin
                 //Logic_Flag_reg = 1'b1;
     case( ALU_FUNC[1:0] )
      2'b00 : begin 
               ALU_Logic = A & B ;
                 Logic_Flag_reg = 1'b1;
              end 
      2'b01 : begin 
               ALU_Logic = A | B ;
                 Logic_Flag_reg = 1'b1; 
              end
      2'b10 : begin 
               ALU_Logic = ~(A & B) ;
		 Logic_Flag_reg = 1'b1; 
              end
      2'b11 : begin 
               ALU_Logic = ~(A | B) ;
		 Logic_Flag_reg = 1'b1;
	      end
     endcase 
    end
  else 
    begin
     ALU_Logic = 16'b0;
     Logic_Flag_reg= 1'b0 ;
    end 
 end 

     /****** Sequential Block ******/
     /******    Regesterd     ******/
always @ (posedge CLK , negedge RST )
 if (!RST)
  begin
   Logic_OUT <=16'b0;
   Logic_Flag <= 'b0;
  end 

 else 
  begin
   Logic_OUT  <= ALU_Logic; 
   Logic_Flag <= Logic_Flag_reg;
  end 
endmodule 