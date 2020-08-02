module GCD_datapath(gt, lr, eq, ldA, ldB, Sel1, Sel2, Sel_in, data_in, clk);
input ldA, ldB, Sel1, Sel2, Sel_in, clk;
input [15:0] data_in;
output gt, lr, eq;
wire [15:0] Aout, Bout, X, Y, Bus, Subout;

	PIPO A (Aout, Bus, ldA, clk);
	PIPO B (Bout, Bus, ldB, clk);
	Mux mux_in1 (X, Aout, Bout, Sel1);
	Mux mux_in2 (Y, Aout, Bout, Sel2);
	Mux mux_load (Bus, Subout, data_in, Sel_in);
	Subtractor sub (Subout, X, Y);
	Compare comp (lr, gt, eq, Aout, Bout);
	
endmodule

module PIPO (data_out, data_in, load, clk);
input [15:0]data_in;
input load, clk;
output reg[15:0]data_out;

	always@(posedge clk)
	if(load) data_out <= data_in;

endmodule

module Subtractor(out, in1, in2);
input [15:0] in1, in2;
output reg[15:0] out;

	always @(*)
	out = in1 - in2;

endmodule

module Compare(lr, gt, eq, data1, data2);
input [15:0] data1, data2;
output lr, gt,eq;

	assign lr = data1 < data2;
	assign gt = data1 > data2;
	assign eq = data1 == data2;

endmodule


module Mux(out, in0, in1, Sel);
input[15:0] in0, in1;
input Sel;
output [15:0] out;

	assign out = Sel ? in1 : in0;

endmodule

module GCD_controlpath(ldA, ldB, Sel1, Sel2, Sel_in, done, clk, lr, gt, eq, start);
input clk, lr, gt, eq, start;
output reg ldA, ldB, Sel1, Sel2, Sel_in, done;
reg [2:0] state;
parameter S0 = 3'b000, S1 = 3'b001,S2 = 3'b010, S3 = 3'b011, S4 = 3'b100, S5 = 3'b101;

	always@(posedge clk)
		begin case(state)
		S0 : if (start) state <= S1;
		S1 : state <= S2;
		S2 : #2 if (eq) state <= S5;
			else if (lr) state <= S3;
			else if (gt) state <= S4;
		S3 : #2 if (eq) state <= S5;
			else if (lr) state <= S3;
			else if (gt) state <= S4;
		S4 : #2 if (eq) state <= S5;
			else if (lr) state <= S3;
			else if (gt) state <= S4;
		S5 : state <= S5;
		default: state <= S0;
		endcase
	end
	
	always@(state)begin 
	case(state)
	S0: begin Sel_in = 1;
		ldA = 1;
		ldB = 0;
		done = 0;
		end
	S1: begin Sel_in = 1;
		ldA = 0;
		ldB = 1;
		end
	S2: if (eq) done = 1;
		else if (lr) 
			begin Sel1 = 1; Sel2 = 0; Sel_in = 0;
			#1 ldA = 0; ldB = 1;
			end
		else if (gt) 
			begin Sel1 = 0; Sel2 = 1; Sel_in = 0;
			#1 ldA = 1; ldB = 0;
			end
	S3: if (eq) done = 1;
		else if (lr) 
			begin Sel1 = 1; Sel2 = 0; Sel_in = 0;
			#1 ldA = 0; ldB = 1;
			end
		else if (gt) 
			begin Sel1 = 0; Sel2 = 1; Sel_in = 0;
			#1 ldA = 1; ldB = 0;
			end
	S4: if (eq) done = 1;
		else if (lr) 
			begin Sel1 = 1; Sel2 = 0; Sel_in = 0;
			#1 ldA = 0; ldB = 1;
			end
		else if (gt) 
			begin Sel1 = 0; Sel2 = 1; Sel_in = 0;
			#1 ldA = 1; ldB = 0;
			end
	S5: begin
		done = 1; Sel1 = 0; Sel2 = 0; Sel_in = 0;
			ldA = 0; ldB = 0;
		end
	default: begin ldA = 0; ldB = 0; end
	endcase
	end
endmodule