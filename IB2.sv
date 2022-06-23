module IB2(
input logic CLK,
input logic RESET,
input logic RTI,
input logic [3:0] REQI,

output logic REQ,
output logic [15:0] ADDRInt
);

reg [1:0] req;
reg int_set;
reg [15:0] addr;

initial
    begin
	 int_set = 1'b0;
	 end

always @(posedge CLK or posedge RESET or posedge RTI)
    begin
	 if (RESET | RTI)
	     begin
		  req = 1'b0;
		  int_set = 1'b0;
		  addr = 16'b0; 
		  end
	 else if (!int_set)
	     begin
		  for (int i = 3; i > -1; i--)
		      begin
				if (REQI[i])
				    begin
					 int_set = 1'b1;
					 req = i;
					 break;
					 end
				end
		  if (int_set)
		      begin
				case (req)
				2'b00: addr = 16'hFFF0;
				2'b01: addr = 16'hFFF2;
				2'b10: addr = 16'hFFFA;
				2'b11: addr = 16'hFFFC;
				endcase
				end
		  else addr = 16'b0;
		  end
	 
	 
	 ADDRInt = addr;
	 REQ = int_set;
	 end

endmodule