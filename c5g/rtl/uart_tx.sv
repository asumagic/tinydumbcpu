`default_nettype none

module uart_tx #(parameter freq_in = 50000000, parameter freq_out = 57600, parameter acc_precision = 16)
(
	input wire clock,

	input reg [7:0] data_in,
	input reg data_coming,

	output reg uart_out/*,

	output reg data_overflow*/
);

parameter increment = ((freq_out << (acc_precision-4)) + (freq_in >> 5))/(freq_in >> 4);

typedef enum logic [2:0]
{
	uart_idle,
	uart_start,
	uart_data,
	uart_stop
} UARTState;

UARTState state;

// HACK
reg [7:0] last_thing;

reg [2:0] current_bit;

reg [acc_precision:0] baud_gen_acc;
wire baud_tick = baud_gen_acc[acc_precision];

initial
begin
	uart_out <= 1;
	state = uart_idle;
end

always @(posedge clock)
begin
	// Increment workaround as per https://www.fpga4fun.com/SerialInterface2.html
	baud_gen_acc <= baud_gen_acc[acc_precision-1:0] + increment;

	if (baud_tick)
	begin
		// Update next state
		case (state)
			
		uart_idle:
		begin
			state <= uart_idle;
			uart_out <= 1;
		end

		uart_start:
		begin
			state <= uart_data;
			uart_out <= 0;
			current_bit <= 0;
		end
		
		uart_data:
		begin
			if (current_bit == 7)
				state <= uart_stop;
			
			current_bit <= current_bit + 1;
			uart_out <= last_thing[current_bit];
		end

		uart_stop:
		begin
			state <= uart_idle;
			uart_out <= 1;
		end

		endcase
	end

	if (state == uart_idle && data_coming)
	begin
		state <= uart_start;
		last_thing <= data_in;
	end
end

endmodule