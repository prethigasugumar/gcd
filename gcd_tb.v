module gcd_test;
reg [15:0] data_in;
reg clk, start;
wire done;

reg [15:0] A, B;
  
GCD_datapath DP (gt, lr, eq, ldA, ldB, Sel1, Sel2, Sel_in, data_in, clk);
GCD_controlpath CP(ldA, ldB, Sel1, Sel2, Sel_in, done, clk, lr, gt, eq, start);

initial
begin 
	clk = 1'b0;
	#3 start = 1'b1;
	#100 $finish;
end

always #5 clk = ~clk;

initial
begin
	#12 data_in = 143;
	#10 data_in = 78;
end
	
initial 
begin
	$monitor ($time, " %d %b ", DP.Aout, done);
    $dumpfile ("gcd.vcd"); $dumpvars(0, gcd_test);
end
	
endmodule