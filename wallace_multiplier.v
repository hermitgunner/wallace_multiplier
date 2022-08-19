module carry_save_adder(
	input [31:0]a, b, cin,
	output [31:0]sum, cout);

	assign sum = a ^ b ^ cin;
	assign cout[0] = 1'b0;
	assign cout[31:1] = (a & b) | (b & cin) | (cin & a);
endmodule

module wallace_multiplier(
	input [15:0] A,B,
	output [31:0] Prod
);
	reg [31 : 0] pProd [15:0];

	integer i;

	always @ (*)
	begin
		for(i = 0; i < 16; i = i +1)	
		begin
			if(A[i] == 1)
				pProd[i] = B << i;
			else
				pProd[i] = 32'h00000000;
		end
	end
		// level = 7
		genvar j;
		wire [31:0]L7pProd [10:0];
		generate
			for (j = 0; j < 5; j = j + 1)
				begin : lev7
					carry_save_adder l7 (pProd[3*j],pProd[3*j+1],pProd[3*j+2],L7pProd[2*j],L7pProd[2*j+1]);
				end
		endgenerate
		assign L7pProd[10] = pProd[15];

		// level = 6
		genvar k;
		wire [31:0] L6pProd [7:0];
		generate
			for (k = 0; k < 3; k = k + 1)
				begin : lev6
					carry_save_adder l6 (L7pProd[3*k],L7pProd[3*k+1],L7pProd[3*k+2],L6pProd[2*k],L6pProd[2*k+1]);
				end
		endgenerate
		assign L6pProd[6] = L7pProd[9];
		assign L6pProd[7] = L7pProd[10];

		// level = 5
		genvar l;
		wire [31:0] L5pProd [5:0];
		generate
			for (l = 0; l < 2; l = l + 1)
				begin : lev5
					carry_save_adder l5 (L6pProd[3*l],L6pProd[3*l+1],L6pProd[3*l+2],L5pProd[2*l],L5pProd[2*l+1]);
				end
		endgenerate
		assign L5pProd[4] = L6pProd[6];
		assign L5pProd[5] = L6pProd[7];

		// level = 4
		genvar m;
		wire [31:0] L4pProd [3:0];
		generate
			for (m = 0; m < 2; m = m + 1)
				begin : lev4
					carry_save_adder l4 (L5pProd[3*m],L5pProd[3*m+1],L5pProd[3*m+2],L4pProd[2*m],L4pProd[2*m+1]);
				end
		endgenerate

		// level = 3
		wire [31:0] L3pProd [2:0];
		carry_save_adder fal3 (L4pProd[0],L4pProd[1],L4pProd[2],L3pProd[0],L3pProd[1]);
		assign L3pProd[2] = L4pProd[3];

		// level =2
		wire [31:0] L2pProd [1:0];
		carry_save_adder fal2 (L3pProd[0],L3pProd[1],L3pProd[2],L2pProd[0],L2pProd[1]);

		// level = 1
		wire ignore_carry;
		n_bit_full_adder #(32) nbifa (L2pProd[0],L2pProd[1],Prod,ignore_carry);

		//assign Prod = L2pProd[0] + L2pProd[1];

endmodule




module full_adder(
	input a,b,cin,
	output sum,cout
);
	assign {cout,sum} = a + b + cin;
endmodule

module half_adder(
	input a,b,
	output sum,cout
);
	assign {cout,sum} = a + b;
endmodule

module n_bit_full_adder #(parameter WIDTH = 16)(
	input [WIDTH - 1 : 0] A,B,
	output wire [WIDTH - 1 : 0] SUM,
	output COUT
);
	wire [WIDTH -1 : 0] SUM_REG;
	wire [WIDTH : 1]cout;
	//integer i;
	
	half_adder HA (A[0],B[0],SUM_REG[0],cout[1]);
	genvar i;
	generate
		
		for (i = 1; i < WIDTH; i = i + 1) 
		begin : full_add
			full_adder FA (A[i],B[i],cout[i],SUM_REG[i],cout[i+1]);
		end
	endgenerate

	assign COUT = cout[WIDTH];
	assign SUM  = SUM_REG;

endmodule

	/*
		if i = 4
		
			dj+1 = (3/2)dj

				. . . .
				. . . .
		=========================
			0 0 0 0 . . . .
			0 0 0 . . . . 0
			0 0 . . . . 0 0
		-------------------------
			0 . . . . 0 0 0
		=========================
			    . . . . . .
			    . . . .
			  . . . .
		=========================
			  . . . . . . .
		+	  . . . .
		=========================
		
		16
		11
		8
		6
		4
		3
		2
*/