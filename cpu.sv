module cpu(
//Входные порты
input logic F1,
input logic F2,
input logic RESET,
input logic [15:0]COMM,
input logic COMME,
input logic [15:0]DMI,
input logic [15:0]SR_IN,

//Выходные порты
output logic [15:0]DMO,
output logic [11:0]DMAW,
output logic [11:0]DMAR,
output logic RDV,
output logic WRV,
output logic [15:0]SR_OUT,
output logic [15:0]ALU_OUT
);

reg [15:0] cpu_comm;

//Парсим команду
reg [3:0] code;
reg ad;
reg [1:0] as;
reg [3:0] scr_i, dst_i;

//Читаем результаты из рег файла
reg [15:0] scr_reg, dst_reg;

//Работы с АЛУ
reg [15:0] op_x, op_y;
reg [15:0] alu_result;
reg [15:0] sr_alu;
reg [15:0] data;

//Сохранение результат
reg wrv_rf;
reg [3:0] wr_reg;

reg read_op; //для поочередного чтения операндов из памяти (0 - пришла команда, 1 - пришли операнды)
reg [1:0] op_data;

//Регистр состояния
reg [15:0] sr;

reg [15:0]rd_addr, wr_addr;

initial
    begin
	 read_op = 1'b0;
	 op_data = 2'b0;
	 wrv_rf = 1'b0;
	 sr = 16'b0;
	 end

reg_file reg_file_inst(.CLK(F1), 
                       .RADDR1(scr_i), 
							  .RADDR2(dst_i), 
							  .RDATA1(scr_reg), 
							  .RDATA2(dst_reg), 
							  .WRV(wrv_rf), 
							  .WADDR(wr_reg), 
							  .WDATA(alu_result)
							  );	 

assign rd_addr = (op_data[1] && as == 2'b01) ? scr_reg - 16'h2400 + COMM :
              (op_data[0]) ? dst_reg - 16'h2400 + COMM : scr_reg - 16'h2400;
assign DMAR = rd_addr[12:1];
assign DMO = alu_result;

assign ALU_OUT = alu_result;

always @(posedge F1 or posedge RESET)
    begin
	 
	 if (RESET)
	     begin
		  cpu_comm = 16'b0;
		  code = 4'b0;
		  dst_i = 4'b0;
		  as = 2'b0;
		  ad = 1'b0;
		  scr_i = 4'b0;
		  op_data = 2'b0;
		  read_op = 1'b0;
		  sr = 16'b0;
		  end
		  
    else if (COMME)
	     begin
		  if (!read_op)
		      begin
				sr = SR_IN;
				WRV = 1'b0;
				cpu_comm = COMM;
				code = COMM[15:12];
				dst_i = COMM[3:0];
				as = COMM[5:4];
				ad = (code > 4'h3) ? COMM[7] : 1'b0;
				scr_i = (code > 4'h3) ? COMM[11:8]: 4'b0;
				op_data = (code > 4'h3) ? {as[0],ad} : {1'b0,as[0]};
				read_op = (!op_data) ? 1'b0 : 1'b1;
				
				RDV = (as == 2'b10) ? 1'b1 : 1'b0;
				end
			else if (op_data[1])
		      begin
				data = COMM;
				if (code > 4'h3) cpu_comm[7] = 1'b0;
				RDV = (as == 2'b01) ? 1'b1 : 1'b0;
				op_data[1] = 1'b0;
				read_op = (!op_data) ? 1'b0 : 1'b1;
		      end
		   else 
		      begin
				if (code > 4'h3)
				    begin
				    cpu_comm[5:4] = 2'b00;
					 cpu_comm[7] = ad;
					 end
				RDV = 1'b1;
		      op_data[0] = 1'b0;
		      read_op = 1'b0;
				WRV = 1'b1;
				wr_addr = dst_reg - 16'h2400 + COMM;
            DMAW = wr_addr[12:1];
		      end
		  end
    end
		  
always @(posedge F2)
    begin
	 if (code > 4'h3)
	     begin
		  case (as)
		  2'b00: op_x = scr_reg;
		  2'b11: op_x = data;
		  endcase
		  if (^as) op_x = DMI;
		  
		  if (!ad) op_y = dst_reg;
		  wrv_rf = (!op_data && !ad) ? 1'b1 : 1'b0;
		  end
	 else if(code == 4'h1)
	     begin
		  if (!as) op_y = dst_reg;
		  wrv_rf = (!op_data && !as) ? 1'b1 : 1'b0;
		  end
	 wr_reg = dst_i;
	 end

assign SR_OUT = sr_alu;
 	 
alu alu_ins(.CLK(F1),
            .OP_X(op_x),
            .OP_Y(op_y),
				.DATA(DMI),
				.SR(sr),
            .COMM_ALU(cpu_comm),
				.DATA_OUT(alu_result),
				.SR_ALU(sr_alu)
				);
endmodule