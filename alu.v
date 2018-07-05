module alu
(
	input wire op,
	input wire en,

	input wire [7:0] data_in,

	output wire [7:0] data_out
);

always @*
begin
	data_out = { 8{1'bZ} };

	if (en)
	begin
		if (op == 0) // inc
			data_out = data_in + 1;
		else if (op == 1) // dec
			data_out = data_in - 1;
	end
end

endmodule