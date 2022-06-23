module prog_seq(
input logic CLK,
input logic CLK2,
input logic RESET,
input logic START,
input logic [15:0]RCOMM,
input logic [15:0]SR_IN,

input logic REQ,
input logic [15:0]ADDR_INT,
output logic RTI,

output logic PM_ENA,
output logic [12:0]RAPM,
output logic [15:0]SR_OUT,
output logic COMME
);

reg [15:0]pc;
reg c_a;
reg pme;
reg comme;

//работа с переходами
reg [3:0] code;
reg [1:0] cond;
reg f_c, f_z, f_n, f_v;
reg j_ena;

//работа со стеком
reg [19:0] d_in, d_out;
reg s_ena, s_rts;

//регистр состояния
reg [15:0] sr;

//работа с прерываниями
int i;
reg stop;
reg jmp_to_int;
reg reti;

task wr_stack;
    input [15:0] save_pc;
    begin
	 s_ena = 1'b1;
	 s_rts = 1'b0;
	 d_in = {save_pc, sr[8], sr[2], sr[1], sr[0]};
	 end
endtask

assign RTI = reti;

stack stack_inst(.CLK2(CLK2),
                 .DI(d_in),
					  .ENA(s_ena),
					  .RTS(s_rts),
					  .DO(d_out)
					  );

initial
    begin
	 j_ena = 1'b0;
	 s_ena = 1'b0;
	 s_rts = 1'b0;
	 sr = 16'b0;
	 i = 0;
	 stop = 1'b0;
	 jmp_to_int = 1'b0;
	 comme = 1'b0;
	 end

always @(posedge CLK or posedge RESET)
    begin
	 if (RESET)
	     begin
		  pc = 16'b0;
		  c_a = 1'b0;
		  pme = 1'b0;
		  sr = 16'b0;
		  comme = 1'b0;
		  end
		  
	 else if (START)
	     begin
		  pc = 16'hFFFF;
		  c_a = 1'b0;
		  pme = 1'b1;
		  sr = 16'b0;
		  comme = 1'b0;
		  end
		  
	 else if (!i && RCOMM == 16'h3FFF) pc = pc;
		  
	 else
	     begin
		  sr = SR_IN;
		  if (REQ && !jmp_to_int && !stop && !reti) stop = 1'b1;
		  
	     if (stop)
	     begin
		  if (!i)
		      begin
				wr_stack(pc);
				pc = ADDR_INT;
		      c_a = 1'b0;
				stop = 1'b0;
				jmp_to_int = 1'b1;
				end
		  else 
		      begin
		      pc = pc + 2;
				s_ena = 1'b0;
	         s_rts = 1'b0;
				i--;
		      end
		  end
		  
		  else if (!c_a)
		     begin
		     pc = (RCOMM[15:14]==2'b11) ? RCOMM : RCOMM*2;
			  c_a = 1'b1;
			  s_ena = 1'b0;
	        s_rts = 1'b0;
			  comme = 1'b1;
			  end
		  else
		     begin
			  reti = 1'b0;
			  if (!i)
			      begin
					code = RCOMM[15:12];
					if (code > 4'h3 && RCOMM != 16'h4130) i = RCOMM[7] + RCOMM[4];
					if (code == 4'h1 && RCOMM[11:8] < 4'h2) i = RCOMM[4];
					end
			  else i--;
			  comme = 1'b0;
		     if (code == 4'h2 || code == 4'h3)
			      begin
					case (RCOMM[11:10])
	            2'b00: j_ena = code[0] ? ~sr[2] : ~sr[1];
	            2'b01: j_ena = code[0] ? ~(sr[2]^sr[8]) : sr[1];
	            2'b10: j_ena = code[0] ? sr[2]^sr[8] : ~sr[0];
	            2'b11: j_ena = code[0] ? 1'b1 : sr[0];
	            endcase
					
			      pc = j_ena ? pc + 2*RCOMM[9:0] : pc + 2; //команды перехода
					s_ena = 1'b0;
	            s_rts = 1'b0;
			      end
					
			  else if ({RCOMM[15:7], 3'b000} == 12'h128) //команда call
			      begin
					pc = pc + 2;
				   c_a = 1'b0;
				   wr_stack(pc+2);
					end
					
			  else if (RCOMM == 16'h4130 || RCOMM[15:8] == 8'h13) //команда ret | reti
			      begin 
				   s_ena = 1'b0;
	            s_rts = 1'b1;
					pc = d_out[19:4];
					sr[0] = d_out[0];
	            sr[1] = d_out[1];
	            sr[2] = d_out[2];
	            sr[8] = d_out[3];
					if (RCOMM[15:8] == 8'h13)
					    begin
						 reti = 1'b1;
						 stop = 1'b0;
				       jmp_to_int = 1'b0;
						 end
					end
	
			  else begin
			      comme = 1'b1;
					pc = pc + 2;
					s_ena = 1'b0;
	            s_rts = 1'b0;
					end
		     end
		  end
	 PM_ENA = pme;
	 RAPM = pc[13:1];
	 SR_OUT = sr;
	 COMME = comme;
	 end
endmodule