module stop_check (

input wire  Sampled_bit,
input wire  Stop_EN,
input wire  CLK,RST,

output reg  Stop_ERR
);

always @(posedge CLK or negedge RST)
begin
      if(!RST)
        begin
             Stop_ERR <='b0;
        end

      else if (Stop_EN)
        begin
          if(Sampled_bit)
            begin
             Stop_ERR <='b0;
            end
          else
            begin
             Stop_ERR <='b1;
            end
       end
end

endmodule 
