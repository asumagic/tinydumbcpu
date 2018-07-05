module control
(
	input wire clock,
	input wire [7:0] opcode,

	output wire tape_fetch,
	output wire tape_writeback,

	output wire sp_fetch,
	output wire sp_writeback,

	output wire opcode_fetch,

	// different from opcode_fetch in that it writes to `data`
	output wire progmem_fetch_high,
	output wire progmem_fetch_low,

	output wire pc_writeback,

	output wire alu_en,
	output wire alu_op,

	output wire pc_inc,

	inout reg [15:0] data
);

	reg [7:0] state;

	initial assign state = 1;
	initial assign data = 0;

always @(posedge clock)
begin
	state <= (state << 1); // shift into the next state

	tape_fetch <= 0;
	tape_writeback <= 0;
	alu_en <= 0;
	alu_op <= 0;
	pc_inc <= 0;

	// Opcode fetch (first stage)
	if (state == (1 << 0))
	begin
		opcode_fetch <= 1'b1;
	end

	// INC opcode
	// fetch mem -> alu inc -> wb mem
	if (opcode == 0)
		case (state)

		(1 << 1): begin
			tape_fetch <= 1;
		end

		(1 << 2): begin
			alu_en <= 1;
			alu_op <= 0;
		end

		(1 << 3): begin
			tape_writeback <= 1;
			pc_inc <= 1;
			state <= 1;
		end

		endcase

	// DEC opcode
	// fetch mem -> alu dec -> wb mem
	else if (opcode == 1)
		case (state)

		(1 << 1): begin
			tape_fetch <= 1;
		end

		(1 << 2): begin
			alu_en <= 1;
			alu_op <= 1;
		end

		(1 << 3): begin
			tape_writeback <= 1;
			pc_inc <= 1;
			state <= 1;
		end

		endcase

	// INCSP opcode
	// fetch sp -> alu inc -> wb sp
	else if (opcode == 2)
		case (state)

		(1 << 1): begin
			sp_fetch <= 1;
		end

		(1 << 2): begin
			alu_en <= 1;
			alu_op <= 0;
		end

		(1 << 3): begin
			sp_writeback <= 1;
			pc_inc <= 1;
			state <= 1;
		end

		endcase

	// DECSP opcode
	// fetch sp -> alu dec -> wb sp
	else if (opcode == 3)
		case (state)

		(1 << 1): begin
			sp_fetch <= 1;
		end

		(1 << 2): begin
			alu_en <= 1;
			alu_op <= 1;
		end

		(1 << 3): begin
			sp_writeback <= 1;
			pc_inc <= 1;
			state <= 1;
		end
		
		endcase

	// RELJMPZ opcode
	// fetch mem -> branch if zero -> fetch low -> fetch high -> wb pc
	else if (opcode == 4)
		case (state)

		(1 << 1): begin
			tape_fetch <= 1;
			pc_inc <= 1; // we want to fetch the next opcode asap
		end

		(1 << 2): // HACKY?
			if (data[7:0] != 0) // check against lower bits of the data
			begin
				// we have incremented pc already! don't do it again
				state <= 1;
			end
			else
			begin
				progmem_fetch_low <= 1;
				pc_inc <= 1;
			end

		(1 << 3): begin
			progmem_fetch_high <= 1;
		end

		(1 << 4): begin
			pc_writeback <= 1;
			state <= 1;
		end

		endcase

	// RELJMPNZ opcode
	// fetch mem -> branch if not zero -> fetch low -> fetch high -> wb pc
	else if (opcode == 5)
		case (state)

		(1 << 1): begin
			tape_fetch <= 1;
			pc_inc <= 1; // we want to fetch the next opcode asap
		end

		(1 << 2): // HACKY?
			if (data[7:0] == 0) // check against lower bits of the data
			begin
				// we have incremented pc already! don't do it again
				state <= 1;
			end
			else
			begin
				progmem_fetch_low <= 1;
				pc_inc <= 1;
			end

		(1 << 3): begin
			progmem_fetch_high <= 1;
		end

		(1 << 4): begin
			pc_writeback <= 1;
			state <= 1;
		end

		endcase

	// CIN opcode
	else if (opcode == 6)
		case (state)

		(1 << 1): begin
			$display("Opcode 6 (cin) not implemented yet");
			pc_inc <= 1;
			state <= 1;
		end

		endcase

	// COUT opcode
	else if (opcode == 7)
		case (state)

		(1 << 1): begin
			tape_fetch <= 1;
		end

		(1 << 2): begin
			$display("%c", data[7:0]);
			pc_inc <= 1;
			state <= 1;
		end

		endcase

	else
	begin
		$display("Unknown instruction, CPU stop!");
		$finish();
	end
end

endmodule