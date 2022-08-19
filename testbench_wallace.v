`include "wallace_multiplier.v"

module testbench;

	reg [15:0] a,b;
	wire [31:0] out;

	wallace_multiplier test (a,b,out);
	
		integer i,j,err_flag;
	initial begin 
		
		$dumpfile("test.vcd");
		$dumpvars(0, testbench);

		#10 a = 1024; b = 1023;
		#10 $display ("a = %d, b = %d , a*b = %d , out = %d\n", a,b,i*j,out);
		for(i = 0; i < 2**5; i = i + 1)

			for (j = 0; j < 2**5; j = j + 1)
			begin
				 a = i; 
				 b = j;
				#10 $display ("a = %d, b = %d , a*b = %d , out = %d\n", a,b,i*j,out);
			end
	end
endmodule
