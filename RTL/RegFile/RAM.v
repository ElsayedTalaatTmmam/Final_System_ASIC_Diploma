module RAM # (
    parameter ADDR_WIDTH = 4,
    parameter MEM_DEPTH = 16,
    parameter MEM_WIDTH = 8,
    parameter PRESCALE = 6'd16 ,
    parameter PAR_TYP = 1'b0 ,
    parameter PAR_EN = 1'b1)
(
    input  wire                   WrEn,RdEn,
    input  wire                   CLK,RST,
    input  wire  [ADDR_WIDTH-1:0] address,
    input  wire  [MEM_WIDTH-1:0]  WrData, 

    output reg                    RdData_Valid,
    output reg   [MEM_WIDTH-1:0]  RdData,

    output [MEM_WIDTH - 1 :0] REG0 ,
    output [MEM_WIDTH - 1 :0] REG1 ,
    output [MEM_WIDTH - 1 :0] REG2 ,
    output [MEM_WIDTH - 1 :0] REG3
);
     integer i;
    // 2D Array
    reg [MEM_WIDTH-1:0] memory [MEM_DEPTH-1:0];  

assign REG0 = memory[0] ;
assign REG1 = memory[1] ;
assign REG2 = memory[2] ;
assign REG3 = memory[3] ;      

    always @(posedge CLK or negedge RST )
	  begin
        if (!RST)
           begin

      memory[4'h0] <= 0;                  // ALU OPERAND A
      memory[4'h1] <= 0;                  // ALU OPERAND B
      memory[4'h2] <= {PRESCALE,PAR_TYP,PAR_EN};  // [7:2]--> Prescale , 1 --> PARITY TYPE , 0 --> PARITY ENABLE
      memory[4'h3] <= 8'd32;              // DIVISION RATION OF CLK DIVIDER

		for (i= 4; i<MEM_DEPTH; i=i+1) 
             begin		
		           memory[i]<='b0;
		     end
        /*  memory[0]<=1'b0;
          memory[1]<=1'b0;
          memory[2]<=1'b0;
          memory[3]<=1'b0;
          memory[4]<=1'b0;
          memory[5]<=1'b0;
          memory[6]<=1'b0;
          memory[7]<=1'b0;*/
              RdData <= 0; 
              RdData_Valid <= 'b0;
            end

        else if (WrEn && !RdEn)
		 begin
              RdData_Valid <= 'b0;
            if (address != 4'h2 && address != 4'h3)
            begin
            memory[address] <= WrData;
            end
		 end

        else if (RdEn && !WrEn)
                 begin
            RdData <= memory[address]; 
              RdData_Valid <= 'b1;
                 end
        else
 		begin
              RdData_Valid <= 'b0;
		end
       end

endmodule
