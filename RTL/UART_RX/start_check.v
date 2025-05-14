module start_check (

input wire  Sampled_bit,
input wire  Start_EN,
input wire  CLK,RST,

output reg  Start_Glitch
);

always @(posedge CLK or negedge RST)
begin
      if(!RST)
        begin
             Start_Glitch <='b0;
        end

      else if (Start_EN)
        begin
          if(Sampled_bit)
            begin
             Start_Glitch <='b1;
            end
          else
            begin
             Start_Glitch <='b0;
            end
       end
end

endmodule 