
`timescale 1ns/1ps

module UART_RX_TB();
parameter  DATA_WD_TB = 8;
//
parameter  CLK_PERIOD = 5 ; 

reg                         CLK_TB;
reg                         RST_TB;
reg                  	    RX_IN_TB;
reg                  	    PAR_EN_TB;
reg                 	    PAR_TYP_TB;
reg                [5:0]    Prescaler_TB; 
wire    [DATA_WD_TB-1:0]    P_DATA_TB;
wire                	    Data_Valid_TB;

///////////////// Design Instaniation //////////////////
//assign Prescaler_TB = 8;


UART_RX /*#(.Data_Width(DATA_WD_TB))*/ DUT (
.CLK(CLK_TB),
.RST(RST_TB),
.RX_IN(RX_IN_TB),
.PAR_EN(PAR_EN_TB),
.PAR_TYP(PAR_TYP_TB),
.Prescaler(Prescaler_TB),
.P_Data(P_DATA_TB), 
.Data_Valid(Data_Valid_TB)
);

///////////////////// Clock Generator //////////////////

always #(CLK_PERIOD/2) CLK_TB = ~CLK_TB ;

initial
 begin
    $dumpfile ("UART_RX_dump.vcd");
    $dumpvars;
 // Initialization
 initialize() ;

 // Reset
 reset() ; 
////////////////////////////////////////// EVEN Parity /////////////////////////////////////
#20
CONFG (1,0,'b01000);
DATA_parity('h746);    //1_1_1010 0011_0
CHECK_OUT_PARITY('h746,0);
			$display(" //  VALID is DONE  // ");
			$display(" 						 ");
#10
////////////////////////////////////////// ODD Parity /////////////////////////////////////
CONFG (1,1,'b01000);
DATA_parity('h7A6);    //1_1_10101011_0
CHECK_OUT_PARITY('h7A6,1);
			$display(" //  VALID is DONE  // ");
			$display(" 						 ");
#10
////////////////////////////////////////// NO Parity /////////////////////////////////////
CONFG (0,0,'b01000);
DATA_noparity('h2A2);   //0110100010
CHECK_OUT_NOPARITY('h2A2,2);
			$display(" //  VALID is DONE  // ");
			$display(" 						 ");
#10

////////////////////////////////////////// VALID not out /////////////////////////////////////
CONFG (0,0,'b01000);
DATA_noparity('h0A2);   //00_1010_0010    stop bit is 0  stop error
CHECK_OUT_NOPARITY('h0A2,3);
			$display(" //  there stop error so VALID not out  // ");
			$display(" 						 ");
#10
////////////////////////////////////////// chechk wrong /////////////////////////////////////
CONFG (0,0,'b01000);
DATA_noparity('h7A2);  
CHECK_wrong('h3F2,4);
			$display(" //  VALID is DONE  // ");
			$display(" 						 ");
#10

#2000
$stop ;
end

/////////////// Signals Initialization //////////////////

task initialize ;
  begin
	CLK_TB            = 1'b0 ;
	RST_TB            = 1'b1 ;   
	RX_IN_TB          = 1'b1 ;
	PAR_EN_TB         = 1'b0 ;
	PAR_TYP_TB        = 1'b0 ;
	Prescaler_TB      = 1'b0 ;
  end
endtask

///////////////////////// RESET /////////////////////////

task reset ;
  begin
	#(CLK_PERIOD) ;
	RST_TB  = 'b0 ;          
	#(CLK_PERIOD) ;
	RST_TB  = 'b1 ;
	#(CLK_PERIOD) ;
  end
endtask


///////////////////////// CONFG /////////////////////////

task CONFG ;
    input         PAR_EN ;
    input         PAR_TYP ;
    input [5:0]   prescale ;
  begin
	PAR_EN_TB    = PAR_EN ;
	PAR_TYP_TB   = PAR_TYP ;
        Prescaler_TB = prescale ;
  end
endtask

////////////////////////////////////////////////////

task DATA_parity ;
 input  [10:0]  DATA ;
integer i;
 begin
     for (i=0;i<=10;i=i+1)
          begin
           repeat (Prescaler_TB) @(posedge CLK_TB) RX_IN_TB = DATA[i] ;
	  end
			$display(" /////////////////////////////////////////// ");
			$display(" /////////////////////////////////////////// ");
			$display(" 						 ");
			$display(" INput= %b ",DATA);
 end
endtask

///////////////////////////////////////////////////

task DATA_noparity ;
 input  [9:0]  DATA ;
integer i;
 begin
     for (i=0;i<=9;i=i+1)
          begin
           repeat (Prescaler_TB) @(posedge CLK_TB) RX_IN_TB = DATA[i] ;
	  end
			$display(" /////////////////////////////////////////// ");
			$display(" /////////////////////////////////////////// ");
			$display(" 						 ");
			$display(" INput= %b ",DATA);
 end
endtask

/////////////////////////////////////////////////////

task CHECK_OUT_PARITY ;
 input  [10:0]  DATA ;
 input  [2:0]  Test_NUM;

 reg    [7:0]   gener_out ,expec_out;  
 reg            parity_bit;
  begin
  
       gener_out = P_DATA_TB;

    if(PAR_EN_TB)
       if(PAR_TYP_TB)
	    parity_bit = ^DATA ;
	else
            parity_bit = ~^DATA ;

    expec_out =  DATA [8:1];

	if(gener_out == expec_out) 
		begin
			$display(" //////////////////////  CHECK_OUT_PARITY  ///////////////////// ");
			$display("Test Case %d is succeeded",Test_NUM);
			$display(" Output= %b ",expec_out);
		end
	else
		begin
			$display(" //////////////////////  CHECK_OUT_PARITY  ///////////////////// ");
			$display("Test Case %d is failed", Test_NUM);
			$display(" Output= %b ",expec_out);
		end


  end
endtask

////////////////////////////////////////////////////////////////////////

task CHECK_OUT_NOPARITY ;
   input  [9:0]  DATA ;
   input  [2:0]  Test_NUM;

   reg    [7:0]   gener_out ,expec_out;  
  begin
 
     gener_out = P_DATA_TB ;
     expec_out =  DATA [8:1] ;

	if(gener_out == expec_out) 
		begin
			$display(" //////////////////////  CHECK_OUT_NOPARITY  ///////////////////// ");
			$display("Test Case %d is succeeded",Test_NUM);
			$display(" Output= %b ",expec_out);
		end
	else
		begin
			$display(" //////////////////////  CHECK_OUT_NOPARITY  ///////////////////// ");
			$display("Test Case %d is failed", Test_NUM);
			$display(" Output= %b ",expec_out);
		end

  end
endtask

task CHECK_wrong;
 input  [10:0]  DATA ;
 input  [2:0]  Test_NUM;

 reg    [7:0]   gener_out ,expec_out;  
 reg            parity_bit;
  begin
  
       gener_out = P_DATA_TB;

    if(PAR_EN_TB)
       if(PAR_TYP_TB)
	    parity_bit = ^DATA ;
	else
            parity_bit = ~^DATA ;

    expec_out =  DATA [8:1];

	if(gener_out != expec_out) 
		begin
			$display(" //////////////////////  CHECK_wrong  ///////////////////// ");
			$display("Test Case %d is succeeded",Test_NUM);
			$display(" Output= %b ",expec_out);

		end
	else
		begin
			$display(" //////////////////////  CHECK_wrong  ///////////////////// ");
			$display("Test Case %d is failed", Test_NUM);
			$display(" Output= %b ",expec_out);
		end
  end
endtask

endmodule 