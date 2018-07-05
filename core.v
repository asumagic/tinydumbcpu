module core
(
	input wire clock
);

reg pc;
initial assign pc = 0;

// Stack pointer (i.e. )
reg sp;
initial assign sp = 0;

/*ram tape
(
	.clock(clock),
	.reset(reset),
	.address(),
	.write_enable(),
	.data_in(),
	.data_out()
)*/

endmodule