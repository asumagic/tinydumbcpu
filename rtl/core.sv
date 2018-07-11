`default_nettype none

module core
(
	input wire clock,

	// Tape memory
	output reg tape_we,
	output reg [15:0] sp,
	input wire [7:0] tape_data_read,
	output reg [7:0] tape_data_write,

	// Program ROM
	output reg [15:0] pc,
	input wire [2:0] pmem_data_read,

	output reg out_en,
	output reg [7:0] out_data
);

// State definitions
`define STATE_WIDTH 3
`define STATE_RESET         `STATE_WIDTH'd0
`define STATE_FETCH         `STATE_WIDTH'd1
`define STATE_DECODE        `STATE_WIDTH'd2
`define STATE_ALU_EXECUTE   `STATE_WIDTH'd3
`define STATE_ALU_WRITEBACK `STATE_WIDTH'd4
`define STATE_SKIP_LEFT     `STATE_WIDTH'd5
`define STATE_SKIP_RIGHT    `STATE_WIDTH'd6

// Instruction definitions
`define INSTR_WIDTH 3
`define INSTR_INC           `INSTR_WIDTH'd0
`define INSTR_DEC           `INSTR_WIDTH'd1
`define INSTR_INCSP         `INSTR_WIDTH'd2
`define INSTR_DECSP         `INSTR_WIDTH'd3
`define INSTR_LLOOP         `INSTR_WIDTH'd4
`define INSTR_RLOOP         `INSTR_WIDTH'd5
`define INSTR_COUT          `INSTR_WIDTH'd6
`define INSTR_CIN           `INSTR_WIDTH'd7

// ALU definitions
`define ALU_OP_WIDTH 1
`define ALU_OP_INC          `ALU_OP_WIDTH'd0
`define ALU_OP_DEC          `ALU_OP_WIDTH'd1

// Comparator definitions
`define CMP_OP_WIDTH 1
`define CMP_OP_IS_Z         `ALU_OP_WIDTH'd0
`define CMP_OP_IS_NZ        `ALU_OP_WIDTH'd1

// Execution type, i.e. the type of operation performed on `STATE_EXECUTE
`define EXEC_WIDTH 2
`define EXEC_ALU            `EXEC_WIDTH'b01
`define EXEC_BRANCHING      `EXEC_WIDTH'b10

// Writeback destinations
`define WB_WIDTH 1
`define WB_SP               `WB_WIDTH'd0
`define WB_TAPE             `WB_WIDTH'd1

// Opcode
reg [`INSTR_WIDTH-1:0] opcode;
reg [7:0] current_cell;

// ALU states
reg [`ALU_OP_WIDTH-1:0] alu_op;
reg [15:0] alu_data;

// Writeback destination state
reg [`WB_WIDTH-1:0] wb_destination;
reg wb_en;

// Op skip for loops
reg [7:0] depth_counter;
reg do_decr_depth;
reg do_incr_depth;

// Machine state
reg [`STATE_WIDTH-1:0] state;

initial
begin
	state = `STATE_RESET;
end

always @(posedge clock)
begin
	alu_data <= 0; // to clean up the upper bits
	out_en <= 0;
	out_data <= 0;
	tape_we <= 0;

	do_decr_depth <= 0;
	do_incr_depth <= 0;

	// Handle what the current state is supposed to do
	case (state)

	`STATE_RESET:
	begin
		state <= `STATE_FETCH;

		// Reset regs
		pc <= 0;
		sp <= 0;
	end

	`STATE_FETCH:
	begin
		state <= `STATE_DECODE;

		// Fetch the opcode
		opcode <= pmem_data_read;

		current_cell <= tape_data_read;
	end

	`STATE_DECODE:
	begin
		state <= `STATE_ALU_EXECUTE;

		current_cell <= 'X;

		case (opcode)

		`INSTR_INC:
		begin
			alu_data[7:0] <= current_cell;
			alu_op <= `ALU_OP_INC;

			wb_destination <= `WB_TAPE;
			wb_en <= 1;
		end

		`INSTR_DEC:
		begin
			alu_data[7:0] <= current_cell;
			alu_op <= `ALU_OP_DEC;

			wb_destination <= `WB_TAPE;
			wb_en <= 1;
		end

		`INSTR_INCSP:
		begin
			alu_data <= sp;
			alu_op <= `ALU_OP_INC;

			wb_destination <= `WB_SP;
			wb_en <= 1;
		end

		`INSTR_DECSP:
		begin
			alu_data <= sp;
			alu_op <= `ALU_OP_DEC;

			wb_destination <= `WB_SP;
			wb_en <= 1;
		end

		`INSTR_LLOOP:
		begin
			if (current_cell == 0)
			begin
				depth_counter <= 0;
				state <= `STATE_SKIP_RIGHT;
			end
			else
			begin
				state <= `STATE_FETCH;
				pc <= pc + 1;
			end
		end

		`INSTR_RLOOP:
		begin
			if (current_cell != 0)
			begin
				depth_counter <= 0;
				state <= `STATE_SKIP_LEFT;
			end
			else
			begin
				state <= `STATE_FETCH;
				pc <= pc + 1;
			end
		end

		`INSTR_COUT:
		begin
			out_en <= 1;
			out_data <= current_cell;
			state <= `STATE_FETCH;
			pc <= pc + 1;
		end

		`INSTR_CIN:
		begin
			$display("unhandled op 'cin'");
			$finish();
		end

		endcase
	end

	`STATE_ALU_EXECUTE:
	begin
		state <= `STATE_ALU_WRITEBACK;

		case (alu_op)
		`ALU_OP_INC: alu_data <= alu_data + 1;
		`ALU_OP_DEC: alu_data <= alu_data - 1;
		default: begin end
		endcase
	end

	`STATE_ALU_WRITEBACK:
	begin
		state <= `STATE_FETCH;
		pc <= pc + 1;

		if (wb_en)
		begin
			case (wb_destination)

			`WB_SP:
			begin
				sp <= alu_data;
			end

			`WB_TAPE:
			begin
				tape_we <= 1;
				tape_data_write <= alu_data[7:0];
			end

			default: begin end

			endcase
		end
	end

	default: begin end

	// ']'
	`STATE_SKIP_LEFT:
	begin
		state <= `STATE_SKIP_LEFT;

		pc <= pc - 1;

		case (pmem_data_read)
		`INSTR_LLOOP: do_decr_depth <= 1;
		`INSTR_RLOOP: do_incr_depth <= 1;
		default: begin end
		endcase

		if (do_incr_depth)
			depth_counter <= depth_counter + 1;

		if (do_decr_depth)
		begin
			depth_counter <= depth_counter - 1;
			if (depth_counter - 1 == 0)
			begin
				state <= `STATE_FETCH;
				pc <= pc + 2;
			end
		end
	end

	// '['
	`STATE_SKIP_RIGHT:
	begin
		state <= `STATE_SKIP_RIGHT;

		pc <= pc + 1;

		case (pmem_data_read)
		`INSTR_LLOOP: do_incr_depth <= 1;
		`INSTR_RLOOP: do_decr_depth <= 1;
		default: begin end
		endcase

		if (do_incr_depth)
			depth_counter <= depth_counter + 1;

		if (do_decr_depth)
		begin
			depth_counter <= depth_counter - 1;
			if (depth_counter - 1 == 0)
			begin
				state <= `STATE_FETCH;
				pc <= pc;
			end
		end
	end

	endcase
end

endmodule