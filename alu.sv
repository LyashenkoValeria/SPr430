module alu(
input logic CLK,
//input logic ENA,
input logic [15:0]OP_X,OP_Y,DATA,
input logic [15:0]SR,
input logic [15:0]COMM_ALU,

output logic [15:0]DATA_OUT,
output logic [15:0]SR_ALU
);

reg [15:0]reg_x, reg_y;
reg [15:0]result;
reg flag_v, flag_n, flag_z, flag_c;

//сложение и вычитание
reg [8:0]add_low, add_high;
reg over_16;

assign reg_x = (COMM_ALU[15:12] > 4'h3 && ^COMM_ALU[5:4]) ? DATA : OP_X;
assign reg_y = ((COMM_ALU[15:12] > 4'h1 && ^COMM_ALU[5:4]) || (COMM_ALU[15:12] > 4'h3 && COMM_ALU[7])) ? DATA : OP_Y;

initial
    begin
	 result = reg_x;
	 over_16= 1'b0;
    end


always@(*)
    begin
	 flag_v = SR[8];
	 flag_n = SR[2];
	 flag_z = SR[1];
	 flag_c = SR[0];
	 
	 case(COMM_ALU[15:12])
	 4'h1: begin
	       if(COMM_ALU[11:8] == 4'h0)
			     begin
				  flag_c = reg_y[0];
				  result = {SR[0], reg_y[15:1]};
				  end
			 if(COMM_ALU[11:8] == 4'h1)
			     begin
				  flag_c = reg_y[0];
				  result = {reg_y[15], reg_y[15:1]};
				  end
				  flag_n = result[15];
              flag_z = (result != 0) ? 1'b0 : 1'b1;
				  flag_v = 1'b0;
          end	 
	 4'h4: result = reg_x;                       //mov

    4'h5: begin                                  //add
	       result = reg_x + reg_y;
			 
			 add_low = {1'b0,reg_x[7:0]}+{1'b0,reg_y[7:0]};
	       add_high = {1'b0,reg_x[15:8]}+{1'b0,reg_y[15:8]}+add_low[8];
	       over_16 = (~reg_x[15] & ~reg_y[15] & add_high[7]) | (reg_x[15] & reg_y[15] & ~add_high[7]);
			 
			 flag_z = (result != 0) ? 1'b0 : 1'b1;
			 flag_n = result[15];
			 flag_c = add_high[8];
			 flag_v = over_16;
	       end
	
    4'h6: begin                                  //addс
	       result = reg_x + reg_y + SR[0];
			 
			 add_low = {1'b0,reg_x[7:0]}+{1'b0,reg_y[7:0]}+SR[0];
	       add_high = {1'b0,reg_x[15:8]}+{1'b0,reg_y[15:8]}+add_low[8];
			 
	       over_16 = (~reg_x[15] & ~reg_y[15] & add_high[7]) | (reg_x[15] & reg_y[15] & ~add_high[7]);
			 
			 flag_z = (result != 0) ? 1'b0 : 1'b1;
			 flag_n = result[15];
			 flag_c = add_high[8];
			 flag_v = over_16;
	       end
	
    4'h7: begin                                  //subс
	       result = ~reg_x + reg_y + SR[0];
			 
			 add_low = {1'b0,~reg_x[7:0]}+{1'b0,reg_y[7:0]}+SR[0];
	       add_high = {1'b0,~reg_x[15:8]}+{1'b0,reg_y[15:8]}+add_low[8];
			 
	       over_16 = (reg_x[15] & ~reg_y[15] & add_high[7]) | (~reg_x[15] & reg_y[15] & ~add_high[7]);
			 
			 flag_z = (result != 0) ? 1'b0 : 1'b1;
			 flag_n = result[15];
			 flag_c = add_high[8];
			 flag_v = over_16;
	       end
			 
    4'h8, 4'h9: begin                           //sub | cmp
	       result = reg_y-reg_x;
			 
			 add_low = {1'b0,~reg_x[7:0]}+{1'b0,reg_y[7:0]}+1'b1;
	       add_high = {1'b0,~reg_x[15:8]}+{1'b0,reg_y[15:8]}+add_low[8];
			 
	       over_16 = (reg_x[15] & ~reg_y[15] & add_high[7]) | (~reg_x[15] & reg_y[15] & ~add_high[7]);
			 
			 flag_z = (result != 0) ? 1'b0 : 1'b1;
			 flag_n = result[15];
			 flag_c = add_high[8];
			 flag_v = over_16;
			 
			 if(COMM_ALU[15:12] == 4'h9) result = reg_y;
	       end
			 
	 4'hC: result = ~reg_x & reg_y;              //bic
	 4'hD: result = reg_x | reg_y;               //bis
	 
	 4'hE: begin
	       result = reg_x ^ reg_y;               //xor
			 flag_v = reg_x[15] & reg_y[15];
			 flag_n = result[15];
			 flag_z = (result != 0) ? 1'b0 : 1'b1;
			 flag_c = ~flag_z;
			 end
			 
	 4'hF, 4'hB: begin 
	       result = reg_x & reg_y;               //and
			 flag_v = 1'b0;
			 flag_n = result[15];
			 flag_z = (result != 0) ? 1'b0 : 1'b1;
			 flag_c = ~flag_z;
			 if(COMM_ALU[15:12] == 4'hB) result = reg_y;
		    end
			 
	 default: result = 4'h0;
	 endcase
    DATA_OUT = result;
	 SR_ALU = {SR[15:9],flag_v, SR[7:3], flag_n, flag_z, flag_c};
	 end


endmodule

