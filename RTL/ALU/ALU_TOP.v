module ALU_TOP #(parameter IN_DATA_WIDTH = 8,parameter Arith_OUT_WIDTH=16 ) ( 
input  wire signed [IN_DATA_WIDTH-1:0]  A , B,
input  wire        [3:0]                ALU_FUNC,
input  wire                             RST,CLK,
input  wire                             Enable,

output wire signed [Arith_OUT_WIDTH-1:0] ALU_OUT,                      
output wire                              OUT_Valid
);

parameter   LOGIC_OUT_WIDTH = IN_DATA_WIDTH ,
            SHIFT_OUT_WIDTH = IN_DATA_WIDTH ,
            CMP_OUT_WIDTH   = 3 ;

// Internal Signal 
wire Arith_Enable;  
wire Logic_Enable;
wire SHIFT_Enable;
wire CMP_Enable;

  wire signed [Arith_OUT_WIDTH-1:0] Arith_OUT;                      
  wire                              Arith_Flag;
 // wire                              Carry_OUT,
  wire        [LOGIC_OUT_WIDTH-1:0] Logic_OUT;                      
  wire                              Logic_Flag;
  wire        [SHIFT_OUT_WIDTH-1:0] SHIFT_OUT;                     
  wire                              SHIFT_Flag;
  wire        [CMP_OUT_WIDTH-1:0]   CMP_OUT;                      
  wire                              CMP_Flag;

// DECODER
DECODER_UNIT DECODER(
.IN  (ALU_FUNC[3:2]),
.SHIFT_Enable(SHIFT_Enable),
.Arith_Enable(Arith_Enable),
.Logic_Enable(Logic_Enable),
.CMP_Enable(CMP_Enable)
);

DEC_OUT # ( .IN_DATA_WIDTH(IN_DATA_WIDTH) ,
            .Arith_OUT_WIDTH(Arith_OUT_WIDTH) ,
			.LOGIC_OUT_WIDTH(LOGIC_OUT_WIDTH) ,
			.SHIFT_OUT_WIDTH(SHIFT_OUT_WIDTH) ,
			.CMP_OUT_WIDTH(CMP_OUT_WIDTH)
			) ARITHMETIC (
.Arith_OUT(Arith_OUT),
.Arith_Flag(Arith_Flag),
.Logic_OUT(Logic_OUT),
.Logic_Flag(Logic_Flag),
.SHIFT_OUT(SHIFT_OUT),
.SHIFT_Flag(SHIFT_Flag),
.CMP_OUT(CMP_OUT),
.CMP_Flag(CMP_Flag),
.ALU_OUT(ALU_OUT),
.OUT_Valid(OUT_Valid)
);

// LOGIC UNIT
LOGIC_UNIT # ( .IN_DATA_WIDTH(IN_DATA_WIDTH) , .OUT_DATA_WIDTH(LOGIC_OUT_WIDTH)) LOGIC (
.A(A),
.B(B),
.ALU_FUNC(ALU_FUNC[1:0]),
.RST(RST),
.CLK(CLK),
.Logic_Enable((Logic_Enable && Enable)),
.Logic_OUT(Logic_OUT),
.Logic_Flag(Logic_Flag)
);

// ARITHMATIC UNIT
ARITHMETIC_UNIT # ( .IN_DATA_WIDTH(IN_DATA_WIDTH) , .OUT_DATA_WIDTH(Arith_OUT_WIDTH)) ARITHMETIC_U0 (
.A(A),
.B(B),
.ALU_FUNC(ALU_FUNC[1:0]),
.RST(RST),
.CLK(CLK),
.Arith_Enable((Arith_Enable && Enable)),
.Arith_OUT(Arith_OUT),
.Arith_Flag(Arith_Flag),
.Carry_OUT(Carry_OUT)
);

// LOGIC UNIT
LOGIC_UNIT # ( .IN_DATA_WIDTH(IN_DATA_WIDTH) , .OUT_DATA_WIDTH(LOGIC_OUT_WIDTH)) LOGIC_U0 (
.A(A),
.B(B),
.ALU_FUNC(ALU_FUNC[1:0]),
.RST(RST),
.CLK(CLK),
.Logic_Enable((Logic_Enable && Enable)),
.Logic_OUT(Logic_OUT),
.Logic_Flag(Logic_Flag)
);

// SHIFT UNIT
SHIFT_UNIT # ( .IN_DATA_WIDTH(IN_DATA_WIDTH) , .OUT_DATA_WIDTH(SHIFT_OUT_WIDTH)) SHIFT (
.A(A),
.B(B),
.ALU_FUNC(ALU_FUNC[1:0]),
.RST(RST),
.CLK(CLK),
.SHIFT_Enable((SHIFT_Enable && Enable)),
.SHIFT_OUT(SHIFT_OUT),
.SHIFT_Flag(SHIFT_Flag)
);

// CMP UNIT
CMP_UNIT # ( .IN_DATA_WIDTH(IN_DATA_WIDTH) , .OUT_DATA_WIDTH(CMP_OUT_WIDTH)) CMP (
.A(A),
.B(B),
.ALU_FUNC(ALU_FUNC[1:0]),
.RST(RST),
.CLK(CLK),
.CMP_Enable((CMP_Enable && Enable)),
.CMP_OUT(CMP_OUT),
.CMP_Flag(CMP_Flag)
);
endmodule 