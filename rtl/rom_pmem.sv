`default_nettype none

module rom_pmem
(
	input wire clock,

	input wire [15:0] address,
	output reg [2:0] data_out
);

reg [2:0] bytes [(1 << 16) - 1:0];

initial
begin
	$readmemb("pmem_bytecode.txt", bytes);
end

always @(negedge clock)
begin
	data_out <= bytes[address];
end

endmodule