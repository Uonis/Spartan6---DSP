module spartan6_DSP48A1
#(
  parameter N=18 ,parameter W=48 ,parameter Q=36 , parameter O = 8 ,  parameter N_1 = 1 ,
  parameter DIRECT = 0 , parameter CASCADE = 1 ,
  parameter OPMODE5 = 0 ,parameter CARRYIN= 1 , parameter RSTTYPE = "SYNC"
)
(
input [O-1:0] opmode,
input dreg , breg, areg, creg,b1_reg,a1_reg , mreg , carryin_reg , carryout_reg ,p_reg,op_reg,
input bin_attribute, carryinsel ,
input clk,
input [N-1:0] a , b , d ,
input [W-1:0] c ,
input [N-1:0] bcin,
input [W-1:0] pcin,
input  carryin ,
input rsta,rstb,rstc,rstd,rstcarry,rstm,rstopmode,rstp,
output     [Q-1:0] m ,
output     [W-1:0] p ,
output     [W-1:0] pcout ,
output     carryout , carryoutf,
output     [N-1:0] bcout ,

input ce_a, ce_b, ce_c, ce_d, ce_m, ce_carryin, ce_opmode, ce_p
);


//nets
wire [7:0] opmode_out ;
///stage_0
wire [N-1:0] d0_out ; 
wire [N-1:0] b_out ;
wire [N-1:0] b0_out ;
wire [N-1:0] a0_out ;
wire [W-1:0] c0_out ;
reg  [N-1:0] out_db ;
//////stage_1

wire [N-1:0] out_1 ;
wire [N-1:0] b1_out, a1_out ;
wire [Q-1:0] out_2 ;

//// stage2
wire [Q-1:0] m_regout ;
wire out_3 , out_4 ;
///stage3
wire [W-1:0] out_muxZ ;
wire [W-1:0] out_muxX ;
///stage4
wire [W-1:0] out_5 ;

//opmode register
reg_mux #(.RSTTYPE(RSTTYPE),.N(O) , .W(O)) opmode_reg (
	.in(opmode),
	.opcode(op_reg),
	.clk(clk) ,
	.ce(ce_opmode),
	.rst(rstopmode), 
	.out(opmode_out) 
);

///stage_0
reg_mux #(.RSTTYPE(RSTTYPE),.N(N) , .W(N)) statu_d0 (
	.in(d),
	.opcode(dreg),
	.clk(clk) ,
	.ce(ce_d),
	.rst(rstd), 
	.out(d0_out) 
);

assign b_out = (bin_attribute == DIRECT)? b :  (bin_attribute == CASCADE)? bcin : 0 ;

reg_mux #(.RSTTYPE(RSTTYPE),.N(N) , .W(N)) statu_b0 (
	.in(b_out),
	.opcode(breg),
	.clk(clk) ,
	.ce(ce_b),
	.rst(rstb), 
	.out(b0_out) 
);

reg_mux #(.RSTTYPE(RSTTYPE),.N(N) , .W(N)) statu_a0 (
	.in(a),
	.opcode(areg),
	.clk(clk) ,
	.ce(ce_a),
	.rst(rsta), 
	.out(a0_out) 
);

reg_mux #(.RSTTYPE(RSTTYPE),.N(W) , .W(W)) statu_c0 (
	.in(c),
	.opcode(creg),
	.clk(clk) ,
	.ce(ce_c),
	.rst(rstc), 
	.out(c0_out) 
);

always @(*)begin
	if(opmode_out[6] == 0 ) begin
		out_db = d0_out + b0_out ;
	end
	else begin
		out_db = d0_out - b0_out ;
	end
end
///stage_1
assign out_1 = (opmode_out[4] == 0 )? b0_out : out_db ;
reg_mux #(.RSTTYPE(RSTTYPE),.N(N) , .W(N)) b1reg (
	.in(out_1),
	.opcode(b1_reg),
	.clk(clk) ,
	.ce(ce_b),
	.rst(rstb), 
	.out(b1_out) 
);

reg_mux #(.RSTTYPE(RSTTYPE),.N(N) , .W(N)) a1reg (
	.in(a0_out),
	.opcode(a1_reg),
	.clk(clk) ,
	.ce(ce_a),
	.rst(rsta), 
	.out(a1_out) 
);
assign out_2 = b1_out * a1_out ;
assign bcout = b1_out ;

//// stage2

reg_mux #(.RSTTYPE(RSTTYPE),.N(Q) , .W(Q)) m_reg (
	.in(out_2),
	.opcode(mreg),
	.clk(clk) ,
	.ce(ce_m),
	.rst(rstm), 
	.out(m_regout) 
);
assign m = m_regout ;
assign out_3 = ( carryinsel == OPMODE5 )? opmode_out[5] : (carryinsel == CARRYIN )? carryin : 0 ; 

reg_mux #(.RSTTYPE(RSTTYPE),.N(N_1) , .W(N_1)) cyi (
	.in(out_3),
	.opcode(carryin_reg),
	.clk(clk) ,
	.ce(ce_carryin),
	.rst(rstcarry), 
	.out(out_4) 
);


//// stage3
assign out_muxX = (opmode_out [1:0] == 0)? 48'b 0 :(opmode_out [1:0] == 1)? opmode_out :(opmode_out [1:0] == 2)? p : {d0_out,a1_out,b1_out} ;
assign out_muxZ = (opmode_out [3:2] == 0)? 48'b 0 :(opmode_out [3:2] == 1)? pcin :(opmode_out [3:2] == 2)? p : c0_out ;

//// stage4
assign out_5 = (opmode_out [7] == 0)? out_muxX + out_muxZ + out_4 : out_muxZ - (out_muxX + out_4) ;

reg_mux #(.RSTTYPE(RSTTYPE),.N(N_1) , .W(N_1)) cyo (
	.in(out_5 [35]),
	.opcode(carryout_reg),
	.clk(clk) ,
	.ce(ce_carryin),
	.rst(rstcarry), 
	.out(carryout) 
);
assign carryoutf = carryout ;

reg_mux #(.RSTTYPE(RSTTYPE),.N(W) , .W(W)) outp (
	.in(out_5),
	.opcode(p_reg),
	.clk(clk) ,	
	.ce(ce_p),
	.rst(rstp), 
	.out(p) 
);
assign pcout = p ;

endmodule
