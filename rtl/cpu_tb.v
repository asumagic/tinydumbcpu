module cpu_tb();

reg clock;
initial clock = 0;

initial
begin
	//$dumpfile("cpu.vcd");
	//$dumpvars(0, cpu_tb);
end

always
begin
	#1 clock = ~clock;
end

cpu cpu_inst
(
	.clock(clock)
);

endmodule