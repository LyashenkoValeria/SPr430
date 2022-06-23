module IB1(
input logic CLK,
input logic RESET,
input logic MASK,
input logic WMASK,
input logic IRQ,
input logic RTI,

output logic REQI
);

reg F1, F2, F3, FIX_INT, WM;

always @(posedge CLK or posedge RESET)
    begin
	 if (RESET) F1 = 1'b0;
	 else F1 = IRQ;
	 end
	 
always @(posedge CLK or posedge RESET)
    begin
	 if (RESET) F2 = 1'b0;
	 else F2 = F1;
	 end
	 
always @(posedge CLK or posedge RESET)
    begin
	 if (RESET) F3 = 1'b0;
	 else F3 = F1 & F2;
	 end
	 
always @(posedge F3 or posedge RESET or posedge RTI)
    begin
	 if (RESET) FIX_INT = 1'b0;
	 else if (RTI) FIX_INT = 1'b0;
	 else FIX_INT = 1'b1;
	 end
	 
always @(posedge WMASK)
    begin
	 if (RESET) WM = 1'b0;
	 else WM = MASK;
	 end
	 
assign REQI = WM & FIX_INT;
endmodule