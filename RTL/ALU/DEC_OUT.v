module DEC_OUT #(parameter IN_DATA_WIDTH = 16 ,
            Arith_OUT_WIDTH = IN_DATA_WIDTH + IN_DATA_WIDTH , // multiply need more bits 
            LOGIC_OUT_WIDTH = IN_DATA_WIDTH ,
            SHIFT_OUT_WIDTH = IN_DATA_WIDTH ,
            CMP_OUT_WIDTH   = 3 )(

input wire signed [Arith_OUT_WIDTH-1:0] Arith_OUT,                      
input wire                              Arith_Flag,
// input wire                              Carry_OUT,
input wire        [LOGIC_OUT_WIDTH-1:0] Logic_OUT,                      
input wire                              Logic_Flag,
input wire        [SHIFT_OUT_WIDTH-1:0] SHIFT_OUT,                      
input wire                              SHIFT_Flag,
input wire        [CMP_OUT_WIDTH-1:0]   CMP_OUT,                      
input wire                              CMP_Flag,

output reg signed [Arith_OUT_WIDTH-1:0] ALU_OUT,                      
output reg                              OUT_Valid

);

wire [3:0] flags;

assign flags = {CMP_Flag,SHIFT_Flag,Logic_Flag,Arith_Flag};

always @ (*)
  begin 
    case( flags )
      'b0001 : begin
				ALU_OUT = Arith_OUT;
				OUT_Valid = Arith_Flag;
              end

      'b0010 : begin
				ALU_OUT = Logic_OUT;
				OUT_Valid = Logic_Flag;
              end
      'b0100 :begin
				ALU_OUT = SHIFT_OUT;
				OUT_Valid = SHIFT_Flag;
              end

      'b1000 : begin
				ALU_OUT = CMP_OUT;
				OUT_Valid = CMP_Flag;
              end
      default : begin
				ALU_OUT = 'b0;
				OUT_Valid = 'b0;
              end
    endcase 
  end
  endmodule