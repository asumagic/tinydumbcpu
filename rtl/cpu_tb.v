module cpu_tb();

wire clock;
always #1 clock <= ~clock;

cpu cpu_inst
(
	.clock(clock)
);

endmodule