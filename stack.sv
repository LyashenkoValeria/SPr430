module stack(
input logic CLK2,
input logic [19:0]DI,
input logic ENA,
input logic RTS,

output logic [19:0]DO
);

reg [19:0] STACK_MEM [3:0];
reg [1:0] SP;
reg stack_over;

initial
    begin
	 SP = 2'b00;
	 stack_over = 1'b0;
	 end

always @(posedge CLK2)
    begin
	 if (ENA && !stack_over)
	     begin
		  STACK_MEM[3] = STACK_MEM[2];
		  STACK_MEM[2] = STACK_MEM[1];
		  STACK_MEM[1] = STACK_MEM[0];
		  STACK_MEM[0] = DI;	  
		  SP = SP+1;
		  if (!SP) stack_over = 1'b1;
		  end
	
	 if (RTS)
	     begin
		  if (!SP) stack_over = 1'b0;
		  STACK_MEM[0] = STACK_MEM[1];
		  STACK_MEM[1] = STACK_MEM[2];
		  STACK_MEM[2] = STACK_MEM[3];
		  STACK_MEM[SP-1] = 20'b0;
		  SP = SP-1;
		  end
	 DO = STACK_MEM[0];
	 end
endmodule