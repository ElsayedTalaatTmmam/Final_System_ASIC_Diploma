module data_sampling (

input wire       RX_IN,
input wire [5:0] prescaler,
input wire       Data_Sample_EN,
input wire [4:0] Edge_Counter,
input wire       CLK,RST,

output reg       Sampling_done,
output reg       Sampled_bit
);

reg  [2:0] samples;
wire [4:0] mid_prescaler;

assign mid_prescaler = prescaler>>1; // mid_prescaler = prescaler/2;

always @(posedge CLK or negedge RST)
begin
     if(!RST)
        begin
             samples <= 'b0;
             Sampling_done  <= 'b0;
        end
     else if (Data_Sample_EN)
        begin
           if (Edge_Counter==(mid_prescaler - 1'b1))
                begin
                   samples[0]<=RX_IN ;
                end
           else if (Edge_Counter==(mid_prescaler))
                begin
                   samples[1]<=RX_IN ;
                end
           else if (Edge_Counter==(mid_prescaler + 1'b1))
                begin
                   samples[2]<=RX_IN ;
             Sampling_done  <= 'b1;
                end
	end
     else
	begin
             samples <= 'b0;
             Sampling_done  <= 'b0;
        end
end

always @ (*)
begin
/////////  case prescaler is 4  
  if((mid_prescaler == 'b000010) && (Edge_Counter == 'b00010))
     begin
         Sampled_bit = RX_IN ;
     end
  else
    begin
     case (samples)
           'b000 ,'b001,
           'b010 ,'b100 : Sampled_bit = 'b0;

           'b111 ,'b011,
           'b110 ,'b101 : Sampled_bit = 'b1;
     endcase  
    end   
 end 

endmodule 