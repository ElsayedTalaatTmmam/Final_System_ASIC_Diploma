module RST_SYNC_TB ();
 
parameter NUM_STAGES_TB = 3 ; 

reg                 CLK_TB ;
reg                 RST_TB ;
wire                SYNC_RST_TB ;



////////// Initial Block ////////
initial
begin

CLK_TB = 1'b0 ;
RST_TB = 1'b1 ;

#7 
RST_TB = 1'b0 ;    

#6 
RST_TB = 1'b1 ; 



#100 ;
$stop ;
    
end  

////////// Clock Generation /////////

always #5 CLK_TB = ! CLK_TB ;

///////////// Instantiation ///////////
					 
RST_SYNC  # ( .NUM_STAGES(NUM_STAGES_TB) )  DUT
(
.CLK(CLK_TB),
.RST(RST_TB),
.SYNC_RST(SYNC_RST_TB)
);

endmodule
