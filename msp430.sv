module msp430(
input logic F1,

input logic RESET,
input logic START,
input logic [1:0] IRQ,
output logic [15:0] ALU_OUT,
output logic [15:0] DMI
);

reg [15:0] TACCR;
reg [1:0] MODE;
wire [15:0] comm;
wire comme;

wire ps_rti, ps_ena;
wire [12:0] ps_ramp;
wire [15:0] ps_sr_out;

wire ib_req;
wire [15:0] ib_addr;

wire irt_A, irt_B;

wire [15:0] cpu_dmo;
wire [11:0] cpu_dmaw, cpu_dmar;
wire cpu_rdv, cpu_wrv, cpu_dms;
wire [15:0] cpu_sr_out;

reg F2;

assign F2 = ~F1;

initial
    begin
	 TACCR = 16'b0;
	 MODE = 2'b0;
	 end

prog_seq prog_seq_inst(.CLK(F1),
                       .CLK2(F2),
							  .RESET(RESET),
							  .START(START),
							  .RCOMM({comm[7:0],comm[15:8]}),
							  .SR_IN(cpu_sr_out),
							  
							  .REQ(ib_req),
							  .ADDR_INT(ib_addr),
							  .RTI(ps_rti),
							  
							  .PM_ENA(ps_ena),
	                    .RAPM(ps_ramp),
		                 .SR_OUT(ps_sr_out),
					        .COMME(comme)		  
                       );

prog_mem prog_mem_inst(.clock(F2),
                       .rden(ps_ena),
							  .address(ps_ramp),
							  
							  .q(comm)
                       );

int_block int_block_inst(.CLK(F1),
                         .RESET(RESET),
								 .IRQ(IRQ),
								 .IRT({irt_A,irt_B}),
								 .RTI(ps_rti),
								 .SR(cpu_sr_out),
								 
								 .REQ(ib_req),
								 .ADDRInt(ib_addr)
                         );	
	
timer timer_A(.CLK(F1),
              .TACCR(TACCR),
				  .MODE(MODE),
				  
				  .IRT(irt_A)
              );	
				  
timer timer_B(.CLK(F1),
              .TACCR(TACCR),
				  .MODE(MODE),
				  
				  .IRT(irt_B)
              );
				  
cpu cpu_inst(.F1(F1),
             .F2(F2),
             .RESET(RESET),
				 .COMM({comm[7:0],comm[15:8]}),
				 .COMME(comme),
				 .DMI({DMI[7:0],DMI[15:8]}),
				 .SR_IN(ps_sr_out),
				 
				 .DMO({cpu_dmo[7:0],cpu_dmo[15:8]}),
				 .DMAW(cpu_dmaw),
				 .DMAR(cpu_dmar),
				 .RDV(cpu_rdv),
				 .WRV(cpu_wrv),
				 .SR_OUT(cpu_sr_out),
				 .ALU_OUT(ALU_OUT)
             );
				 
data_mem data_mem_inst(.clock(F2),

							  .data(cpu_dmo),
							  .wraddress(cpu_dmaw),
							  .wren(cpu_wrv),
							  
							  .rdaddress(cpu_dmar),
							  .rden(cpu_rdv),
							  
							  .q(DMI)
                       );

endmodule