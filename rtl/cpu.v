module cpu
(
	input clock
);

wire tape_we;
wire [15:0] tape_addr;
wire [7:0] tape_data_write;
wire [7:0] tape_data_read;

wire [15:0] pmem_addr;
wire [2:0] pmem_data_read;

ram tape
(
	.write_enable(tape_we),
	.address     (tape_addr),
	.data_in     (tape_data_write),
	.data_out    (tape_data_read)
);

rom_pmem pmem
(
	.address (pmem_addr),
	.data_out(pmem_data_read)
);

core cpu
(
	.clock          (clock),
	.tape_we        (tape_we),
	.sp             (tape_addr),
	.tape_data_read (tape_data_read),
	.tape_data_write(tape_data_write),
	.pc             (pmem_addr),
	.pmem_data_read (pmem_data_read)
);

endmodule