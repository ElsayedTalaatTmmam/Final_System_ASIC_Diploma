module CMP_UNIT # ( parameter IN_DATA_WIDTH = 16 , OUT_DATA_WIDTH = 3 )(

input  wire signed [IN_DATA_WIDTH-1:0]  A , B,
input  wire        [1:0]                ALU_FUNC,
input  wire                             RST,CLK,
input  wire                             CMP_Enable,                       
output reg        [OUT_DATA_WIDTH-1:0]  CMP_OUT,                      
output reg                              CMP_Flag
);

     /****** Internal Signal ******/
       reg  [OUT_DATA_WIDTH-1:0] ALU_CMP ;
       reg                       CMP_Flag_reg ;
     /****** Combinational Block ******/
always @ (*)
 begin 
  if ( CMP_Enable )
    begin
               CMP_Flag_reg = 1'b1;
     case( ALU_FUNC[1:0]  )
      2'b00 : begin 
               ALU_CMP = 1'b0  ;
               CMP_Flag_reg = 1'b0;
              end 

      2'b01 : if (A==B)
                   ALU_CMP=16'b01;
              else ALU_CMP=16'b0;

      2'b10 : if (A>B)
                   ALU_CMP=16'b10;
              else ALU_CMP=16'b0;
           
      2'b11 : if (A<B)
                   ALU_CMP=16'b11;
              else ALU_CMP=16'b0;
     endcase 
    end
  else 
    begin
     ALU_CMP = 16'b0;
     CMP_Flag_reg= 1'b0 ;
    end 
 end 

     /****** Sequential Block ******/
     /******    Regesterd     ******/
always @ (posedge CLK , negedge RST )
 if (!RST)
  begin
   CMP_OUT <=16'b0;
   CMP_Flag <= 'b0 ;
  end 

 else 
  begin
   CMP_OUT  <= ALU_CMP;
   CMP_Flag <= CMP_Flag_reg ;   
  end 
endmodule 