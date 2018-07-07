module ram #(parameter addr_bits = 16, parameter data_bits = 8)
(
	input wire clock,

	input wire write_enable,

	input wire [addr_bits - 1:0] address,

	input wire [data_bits - 1:0] data_in,
	output reg [data_bits - 1:0] data_out
);

	reg [data_bits - 1:0] bytes [(1 << addr_bits) - 1:0];

	integer i; // For memory initialization

initial
begin
	for (i = 0; i < (1 << addr_bits) - 1; i = i + 1)
	begin
		bytes[i] <= { data_bits{1'b0} };
	end
end

always @(address, write_enable)
begin
	data_out <= bytes[address];

	if (write_enable)
	begin
		bytes[address] <= data_in;
	end
end

endmodule