module deserializer #(parameter Data_Width=8) (

input wire                  Sampled_bit,
input wire                  DESER_EN, 
input wire                  CLK,RST,

output wire [Data_Width-1:0] P_DATA_d
);

reg [Data_Width-1:0] SER_DATA;
 
always @(posedge CLK or negedge RST)
begin
      if(!RST)
        begin
             SER_DATA <=8'b0;
        end

      else if (DESER_EN)
        begin
          //  SER_DATA <= (Sampled_bit>>7) ;
            SER_DATA <= {Sampled_bit,SER_DATA[Data_Width-1:1]};
        end
/*
      else if (DESER_EN)
        begin
            P_DATA <= (Sampled_bit>>7)
        end
*/
end

assign P_DATA_d = SER_DATA;
endmodule 