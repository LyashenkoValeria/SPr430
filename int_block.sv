module int_block(
input logic CLK,
input logic RESET,
input logic [1:0] IRQ,
input logic [1:0] IRT,
input logic RTI,
input logic [15:0]SR,

output logic REQ,
output logic [15:0] ADDRInt
);

reg [3:0] int_in;
reg [3:0] interrupt;

assign int_in = {IRQ,IRT};
	 
IB1 irq1(.CLK(CLK),
         .RESET(RESET),
         .MASK(SR[12]),
         .WMASK(SR[3]),
         .IRQ(int_in[3]),
			.RTI(RTI),
			
         .REQI(interrupt[3])
);

IB1 irq0(.CLK(CLK),
         .RESET(RESET),
         .MASK(SR[11]),
         .WMASK(SR[3]),
         .IRQ(int_in[2]),
			.RTI(RTI),
			
         .REQI(interrupt[2])
);

IB1 irt1(.CLK(CLK),
         .RESET(RESET),
         .MASK(SR[10]),
         .WMASK(SR[3]),
         .IRQ(int_in[1]),
			.RTI(RTI),
			
         .REQI(interrupt[1])
);

IB1 irt0(.CLK(CLK),
         .RESET(RESET),
         .MASK(SR[9]),
         .WMASK(SR[3]),
         .IRQ(int_in[0]),
			.RTI(RTI),
			
         .REQI(interrupt[0])
);

IB2 ib2_inst(.CLK(CLK),
         .RESET(RESET),
         .RTI(RTI),
         .REQI(interrupt),

         .REQ(REQ),
         .ADDRInt(ADDRInt)
);
endmodule