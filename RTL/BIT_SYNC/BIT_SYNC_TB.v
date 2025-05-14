module BIT_SYNC_TB ();
 
parameter NUM_STAGES_TB = 3 ;
parameter BUS_WIDTH_TB  = 3 ; 

reg                           CLK_TB     ;
reg                           RST_TB     ;
reg      [BUS_WIDTH_TB-1:0]   ASYNC_TB   ;
wire     [BUS_WIDTH_TB-1:0]   SYNC_TB    ;



////////// Initial Block ////////
initial
begin

CLK_TB = 1'b0 ;
RST_TB = 1'b1 ;
ASYNC_TB = 'b0 ;

#7 
RST_TB = 1'b0 ;    

#8 
RST_TB = 1'b1 ; 

#13    
ASYNC_TB = 'b101;


#100 ;
$stop ;
    
end  

////////// Clock Generation /////////

always #5 CLK_TB = ! CLK_TB ;

///////////// Instantiation ///////////
					 
BIT_SYNC  # ( .NUM_STAGES(NUM_STAGES_TB) , .BUS_WIDTH(BUS_WIDTH_TB) )  DUT
(
.CLK(CLK_TB),
.RST(RST_TB),
.ASYNC(ASYNC_TB),
.SYNC(SYNC_TB)
);

endmodule
