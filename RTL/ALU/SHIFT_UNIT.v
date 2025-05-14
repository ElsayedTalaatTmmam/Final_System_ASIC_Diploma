module SHIFT_UNIT # ( parameter IN_DATA_WIDTH = 16 , OUT_DATA_WIDTH = 16 )(

input  wire signed [IN_DATA_WIDTH-1:0]  A , B,
input  wire        [1:0]                ALU_FUNC,
input  wire                             RST,CLK,
input  wire                             SHIFT_Enable,                       
output reg        [OUT_DATA_WIDTH-1:0]  SHIFT_OUT,                      
output reg                              SHIFT_Flag
);

     /****** Internal Signal ******/
       reg  [OUT_DATA_WIDTH-1:0] ALU_SHIFT ;
       reg                       SHIFT_Flag_reg ;
     /****** Combinational Block ******/
always @ (*)
 begin 
  if ( SHIFT_Enable )
    begin
                 //SHIFT_Flag_reg = 1'b1;
     case( ALU_FUNC[1:0]  )
      2'b00 : begin 
               ALU_SHIFT = A >> 1 ;
                 SHIFT_Flag_reg = 1'b1;
              end 
      2'b01 : begin 
               ALU_SHIFT = A << 1 ;
                 SHIFT_Flag_reg = 1'b1; 
              end
      2'b10 : begin 
               ALU_SHIFT = B >> 1 ;
		 SHIFT_Flag_reg = 1'b1; 
              end
      2'b11 : begin 
               ALU_SHIFT = B << 1 ;
		 SHIFT_Flag_reg = 1'b1;
	      end
     endcase 
    end
  else 
    begin
     ALU_SHIFT = 16'b0;
     SHIFT_Flag_reg= 1'b0 ;
    end 
 end 

     /****** Sequential Block ******/
     /******    Regesterd     ******/
always @ (posedge CLK , negedge RST )
 if (!RST)
  begin
   SHIFT_OUT <=16'b0;
   SHIFT_Flag <= 'b0;
  end 

 else 
  begin
   SHIFT_OUT  <= ALU_SHIFT; 
      SHIFT_Flag <= SHIFT_Flag_reg;
  end 
endmodule 