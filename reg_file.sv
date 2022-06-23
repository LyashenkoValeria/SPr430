module reg_file(
input logic CLK,
//чтение из регистров
input logic [3:0] RADDR1, RADDR2,
output logic [15:0] RDATA1, RDATA2,

//запись в регистр
input logic WRV,
input logic [3:0] WADDR,
input logic [15:0] WDATA
);

reg [15:0] regs [15:0];

always @(posedge CLK)
    if(WRV) regs[WADDR] <= WDATA;

assign RDATA1 = RADDR1 ? regs[RADDR1] : 0;
assign RDATA2 = RADDR2 ? regs[RADDR2] : 0;

endmodule