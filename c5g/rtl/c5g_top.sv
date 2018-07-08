`default_nettype none

module c5g_top
(
	input wire CLOCK_125_p,
	input wire CLOCK_50_B5B,
	input wire CLOCK_50_B6A,
	input wire CLOCK_50_B7A,
	input wire CLOCK_50_B8A,

	output wire [6:0] HEX0,
	output wire [6:0] HEX1,
	output wire [6:0] HEX2,
	output wire [6:0] HEX3,

	input wire UART_RX,
	output wire UART_TX
);

reg [7:0] cpu_out_data;
reg cpu_out_en;
reg data_overflow;

cpu cpu_inst
(
	.clock   (CLOCK_50_B7A),
	.out_en  (cpu_out_en),
	.out_data(cpu_out_data)
);

uart_tx tx
(
	.clock        (CLOCK_50_B7A),
	.data_in      (cpu_out_data),
	.data_coming  (cpu_out_en),
	.uart_out     (UART_TX)
);

always
begin
	HEX0 <= '1;
	HEX1 <= '1;
	HEX2 <= '1;
	HEX3 <= '0;
end

endmodule