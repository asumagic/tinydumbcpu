module ram #(parameter addr_bits = 16, parameter data_bits = 8)
(
	input wire clock,

	input wire write_enable,

	input wire [addr_bits - 1:0] address,

	input wire [(1 << data_bits) - 1:0] data_in,
	output reg [(1 << data_bits) - 1:0] data_out
);

	reg [(1 << data_bits) - 1:0] bytes [(1 << addr_bits) - 1:0];

always @(posedge clock)
begin
	data_out <= bytes[address];

	if (write_enable)
	begin
		bytes[address] <= data_in;
	end
end

endmodule