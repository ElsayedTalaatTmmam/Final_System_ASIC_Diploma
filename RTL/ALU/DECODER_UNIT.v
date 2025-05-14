module DECODER_UNIT (

input   wire [1:0] IN,
output  reg        SHIFT_Enable,Arith_Enable,Logic_Enable,CMP_Enable                           
);

always @ (*)
 begin 
    case( IN[1:0] )
      2'b00 : begin
              SHIFT_Enable=1'b0;
              Arith_Enable=1'b1;//
              Logic_Enable=1'b0;
              CMP_Enable  =1'b0;
              end

      2'b01 : begin
              SHIFT_Enable=1'b0;
              Arith_Enable=1'b0;
              Logic_Enable=1'b1;//
              CMP_Enable  =1'b0;
              end
      2'b10 :begin
              SHIFT_Enable=1'b0;
              Arith_Enable=1'b0;
              Logic_Enable=1'b0;
              CMP_Enable  =1'b1;//
              end
      2'b11 : begin
              SHIFT_Enable=1'b1;//
              Arith_Enable=1'b0;
              Logic_Enable=1'b0;
              CMP_Enable  =1'b0;
              end
      default : begin
              SHIFT_Enable=1'b0;
              Arith_Enable=1'b0;
              Logic_Enable=1'b0;
              CMP_Enable  =1'b0;
              end
    endcase 
  end
endmodule
