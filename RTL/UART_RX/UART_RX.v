module UART_RX # (parameter Data_Width=8) (

input wire                   CLK, RST,
input wire                   PAR_TYP,
input wire                   PAR_EN,
input wire                   RX_IN,
input wire    [5:0]          Prescaler,

output wire                  parity_err,
output wire                  stop_err,
output wire                  Data_Valid,
output wire [Data_Width-1:0] P_Data
);

wire       done ;
wire       sample_done ;
wire       strt_glitch ;

wire [2:0] bit_cnt ;
wire [4:0] edge_cnt ;
wire       sample_data_en;
wire       deserial_en ;
wire       sample_bit ;
wire       strt_en ;
wire       stop_en ;
wire       parity_en ;
wire       edge_cnt_en ;
wire       bit_cnt_en ;
 // reg       Data_valid_comb;
 // reg [7:0] P_Data_comb;


FSM_RX #(.Data_Width(Data_Width)) U0_FSM(
.CLK(CLK),//
.RST(RST),//
.Sampling_done(sample_done), 
.Done(done),
.Start_Glitch(strt_glitch),
.Stop_ERR(stop_err), 
.Parity_ERR(parity_err),
.Bit_Counter(bit_cnt), 
.PAR_EN(PAR_EN),//
.RX_IN(RX_IN), //
.Data_Valid(Data_Valid),
.Data_Sample_EN(sample_data_en), 
.DESER_EN(deserial_en),
.Start_EN(strt_en),
.Stop_EN(stop_en), 
.Parity_EN(parity_en),
.Edge_EN_CNT(edge_cnt_en),
.Bit_EN_CNT(bit_cnt_en)
);

///////////////////////////////////////////////////////////////////////////

data_sampling  U0_data_sampling (
.CLK(CLK),
.RST(RST),
.RX_IN(RX_IN), 
.prescaler(Prescaler),
.Data_Sample_EN(sample_data_en), 
.Edge_Counter(edge_cnt),
.Sampling_done(sample_done), 
.Sampled_bit(sample_bit)
);

///////////////////////////////////////////////////////////////////////////

deserializer  # (.Data_Width(Data_Width)) U0_deserializer (
.CLK(CLK),
.RST(RST),
.DESER_EN(deserial_en), 
.Sampled_bit(sample_bit),
.P_DATA_d(P_Data)
);

///////////////////////////////////////////////////////////////////////////

Edge_Bit_Counter  U0_Edge_Bit_Counter (
.CLK(CLK),
.RST(RST),
.prescaler(Prescaler), 
.Bit_EN_CNT(bit_cnt_en),
.Edge_EN_CNT(edge_cnt_en), 
.Bit_Counter(bit_cnt),
.Edge_Counter(edge_cnt), 
.Done(done)
);

///////////////////////////////////////////////////////////////////////////

start_check  U0_start (
.CLK(CLK),
.RST(RST),
.Sampled_bit(sample_bit), 
.Start_EN(strt_en),
.Start_Glitch(strt_glitch)
);

///////////////////////////////////////////////////////////////////////////

stop_check  U0_stop (
.CLK(CLK),
.RST(RST),
.Sampled_bit(sample_bit), 
.Stop_EN(stop_en),
.Stop_ERR(stop_err)
);

///////////////////////////////////////////////////////////////////////////

parity_check  # (.Data_Width(Data_Width)) U0_parity (
.CLK(CLK),
.RST(RST),
.Sampled_bit(sample_bit), 
.Parity_EN(parity_en),
.Parity_TYP(PAR_TYP),
.P_DATA_par(P_Data), 
.Parity_ERR(parity_err)
);

endmodule
