`default_nettype none

module ram #(parameter addr_bits = 16, parameter data_bits = 8)
(
	input wire clock,

	input wire write_enable,

	input wire [addr_bits - 1:0] address,

	input wire [data_bits - 1:0] data_in,
	output reg [data_bits - 1:0] data_out
);

	reg [data_bits - 1:0] bytes [(1 << addr_bits) - 1:0];

initial
begin
	bytes = '{default:0};
end

always @(negedge clock)
begin
	if (write_enable)
	begin
		bytes[address] <= data_in;
		data_out <= 'X;
	end
	else
	begin
		data_out <= bytes[address];
	end
end

endmodule