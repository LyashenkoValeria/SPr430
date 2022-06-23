module timer(
input logic CLK,
input logic [15:0] TACCR,
input logic [1:0] MODE,

output logic IRT
);

reg [15:0] taccr0; 
reg [15:0] tar;
reg [2:0] tacrl; //2-1 - режим, 0 - stop/start
reg rev_count; //прямой - 1, обратный - 0

reg req;

always @(posedge CLK)
    begin
	 req = 1'b0;
	 if ((TACCR > 16'b0) && !tacrl[0])
	     begin
		  taccr0 = TACCR;
		  tacrl[0] = !MODE ? 1'b0 : 1'b1;
		  tacrl[2:1] = MODE;
		  tar = 16'b0;
		  rev_count = 1'b1;
		  end
		  
	 else if (TACCR == 16'b0 || MODE == 2'b0) 
	     begin
	     tacrl[0] = 1'b0;
		  tar = 16'b0;
		  end
	 
	 else if(tacrl[0])
	     begin
		  case(tacrl[2:1])
		  2'b01: begin
		         if (tar == taccr0)
					    begin
						 req = 1'b1;
						 tar = 1'b0;
						 end
					else tar++;
		         end
		  2'b10: begin
		         if (tar == 16'hFFFF)
					    begin
						 req = 1'b1;
						 tar = 1'b0;
						 end
		         else tar++;
		         end
		  2'b11: begin
		         if (!tar && !rev_count)
					    begin
						 req = 1'b1;
						 rev_count = ~rev_count;
						 end
						 
					if (tar == taccr0) rev_count = ~rev_count;
		
		         if (rev_count) tar++;
					else tar--;
		         end
		  endcase
		  end
	 end
	 
assign IRT = req;
endmodule