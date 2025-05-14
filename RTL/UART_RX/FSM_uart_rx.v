module FSM_RX  #(parameter Data_Width=8)(

input wire       RX_IN,
input wire       PAR_EN,
input wire [2:0] Bit_Counter,
input wire       Parity_ERR,
input wire       Stop_ERR,
input wire       Start_Glitch,
input wire       Done,
input wire       Sampling_done,
input wire       CLK,RST,

output reg       Data_Valid,
output reg       Data_Sample_EN,
output reg       DESER_EN,
output reg       Start_EN,
output reg       Stop_EN,
output reg       Parity_EN,
output reg       Edge_EN_CNT,
output reg       Bit_EN_CNT
);

localparam [2:0] IDEAL  = 'b000;
localparam [2:0] START  = 'b001;
localparam [2:0] DATA   = 'b010;
localparam [2:0] PARITY = 'b011;
localparam [2:0] STOP   = 'b100;
localparam [2:0] OUT    = 'b101;


reg [2:0] current_state , next_state ;

always @(posedge CLK or negedge RST)
begin
      if(!RST)
        begin
          current_state <= IDEAL;
        end
     else 
	begin
          current_state <= next_state;
	end
end

always @(*)
begin
             Start_EN ='b0;
             DESER_EN ='b0;
             Data_Sample_EN ='b0;
             Parity_EN ='b0;
             Edge_EN_CNT ='b0;
             Bit_EN_CNT ='b0;
             Data_Valid ='b0;
             Stop_EN ='b0;

  case(current_state)

		IDEAL: begin if (RX_IN)  ///--------------->>
			 begin
			   next_state = IDEAL;
			 end

		        else
			 begin
			   next_state = START;
			 end
			end
/////////////////////////////////////////////////////////////////////////////////////////////
		START: begin if(Done)
			begin
		      	  if (Start_Glitch)  ///--------------->>
			    begin
			      next_state = IDEAL;
			    end
		          else
			    begin
			      next_state = DATA;
			    end
			  end

			else
			    begin
			      next_state = START;
			    end

                                     Start_EN ='b1;
                                     Data_Sample_EN ='b1;
                                     Edge_EN_CNT ='b1;
			end
/////////////////////////////////////////////////////////////////////////////////////////////

		DATA: begin if ((Bit_Counter == (Data_Width-1)) && Done )  ///--------------->>
			begin
			 if (PAR_EN)
			  begin
			    next_state = PARITY;
			  end
			 else
			  begin
			    next_state = STOP;
			  end
			end

		       else
			begin
			  next_state = DATA;
			end

                                     Bit_EN_CNT ='b1;
                                     Data_Sample_EN ='b1;
                                     Edge_EN_CNT ='b1;
                    if (Done) begin  DESER_EN ='b1; end

			end

/////////////////////////////////////////////////////////////////////////////////////////////

		PARITY: begin if (PAR_EN && Done)  ///--------------->>
			 begin
		      	  if (Parity_ERR)  
			    begin
			      next_state = IDEAL;
			    end
		          else
			    begin
			      next_state = STOP;
			    end
			  end

			 else
			    begin
			      next_state = PARITY;
			    end

                                     Parity_EN ='b1;
                                     Data_Sample_EN ='b1;
                                     Edge_EN_CNT ='b1;
			end

//////////////////////////////////////////////////////////////////////////////////////////

		STOP: begin if (Done)  ///--------------->>
			begin
		      	  if (Stop_ERR)  
			    begin
			      next_state = IDEAL;
			    end
		          else
			    begin
			      next_state = OUT;
                                     Data_Valid = 'b1;
			    end
                         end

			else
			    begin
			      next_state = STOP;
			    end

                                     Stop_EN ='b1;
                                     Data_Sample_EN ='b1;
                                     Edge_EN_CNT ='b1;
		     end

//////////////////////////////////////////////////////////////////////////////////////////

		OUT: begin if (RX_IN)  ///--------------->>
			 begin
			   next_state = IDEAL;
			 end

		        else
			 begin
			   next_state = START;
			 end
                                     Data_Valid = 'b1;
		      end

//////////////////////////////////////////////////////////////////////////////////////////

		default : begin
			   next_state = IDEAL;
			  end
     endcase
end

endmodule 
