module reg_mux
#(parameter RSTTYPE = "SYNC" , parameter N = 0,parameter W=0 )
 (
input [N-1:0]in,
input opcode, ce ,
input clk , rst, 
output reg [W-1:0]out 
);
reg out_reg ;
generate
	if(RSTTYPE == "SYNC")begin
		always @(posedge clk)begin
			if(rst) begin
				out_reg <= 0 ;
			end
			else if(ce)begin
				out_reg <= in ;
			end
		end
	end
	else begin
		always @(posedge clk , posedge rst )begin
			if(rst) begin
				out_reg <= 0 ;
			end
			else if (ce) begin
			out_reg <= in ;
			end
		end
	end
endgenerate
always@(*)begin
	out = (opcode == 0)?in:out_reg;
end

endmodule
