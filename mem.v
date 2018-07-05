// memory control: registers and ram
module mem
(
	input wire clock,

	input wire tape_fetch,
	input wire tape_writeback,

	input wire sp_fetch,
	input wire sp_writeback,

	input wire progmem_fetch_high,
	input wire progmem_fetch_low,

	input wire pc_writeback,

	output wire [15:0] data
);

wire [7:0] data_low;
wire [7:0] data_high;

wire tape_we;
wire [7:0] tape_data_in;
wire [7:0] tape_data_out;
wire [15:0] tape_address;

always @*
begin
	data_high = { 8{1'Z} };
	data_low = { 8{1'Z} };

	tape_we = 0;
	tape_data_in = 0;

	if (tape_fetch)
		data_low = tape_data_out;
	
	if (tape_writeback)
		

	data[15:8] = data_high;
	data[7:0] = data_low;
end

ram tape
(
	.clock(clock),

	.write_enable(tape_we),

	.address(tape_address),
	.data_in(tape_data_in),
	.data_out(tape_data_out)
)

endmodule