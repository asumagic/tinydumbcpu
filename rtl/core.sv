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
`define STATE_SKIP          `STATE_WIDTH'd5

// Skip direction definitions (for lloop/rloop)
`define SKIP_DIR_LEFT        1'd0
`define SKIP_DIR_RIGHT       1'd1

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

// ALU states
reg [`ALU_OP_WIDTH-1:0] alu_op;
reg [15:0] alu_data;

// Writeback destination state
reg [`WB_WIDTH-1:0] wb_destination;
reg wb_en;

// Op skip for loops
reg [15:0] depth_counter;
reg skip_dir;

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
		opcode <= pmem_data_read[`INSTR_WIDTH-1:0];
	end

	`STATE_DECODE:
	begin
		state <= `STATE_ALU_EXECUTE;

		//$display("Decoding pc %d, opcode %d, tape %d", pc, opcode, tape_data_read);

		case (opcode)

		`INSTR_INC:
		begin
			alu_data[7:0] <= tape_data_read;
			alu_op <= `ALU_OP_INC;

			wb_destination <= `WB_TAPE;
			wb_en <= 1;
		end

		`INSTR_DEC:
		begin
			alu_data[7:0] <= tape_data_read;
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
			if (tape_data_read == 0)
			begin
				depth_counter <= 0;
				skip_dir <= `SKIP_DIR_RIGHT;
				state <= `STATE_SKIP;
			end
			else
			begin
				state <= `STATE_FETCH;
				pc <= pc + 1;
			end
		end

		`INSTR_RLOOP:
		begin
			if (tape_data_read != 0)
			begin
				depth_counter <= 0;
				skip_dir <= `SKIP_DIR_LEFT;
				state <= `STATE_SKIP;
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
			out_data <= tape_data_read;
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

	`STATE_SKIP:
	begin
		state <= `STATE_SKIP;

		//$display("skip cycle, pc %d, depth %d", pc, depth_counter);

		case (skip_dir)

		// ']'
		`SKIP_DIR_LEFT:
		begin
			pc <= pc - 1;

			case (pmem_data_read)

			`INSTR_LLOOP:
			begin
				depth_counter <= depth_counter - 1;

				if ((depth_counter - 1) == 0)
				begin
					pc <= pc;
					state <= `STATE_FETCH;
				end
			end

			`INSTR_RLOOP: depth_counter <= depth_counter + 1;

			default: begin end

			endcase
		end

		// '['
		`SKIP_DIR_RIGHT:
		begin
			pc <= pc + 1;

			case (pmem_data_read)

			`INSTR_LLOOP: depth_counter <= depth_counter + 1;

			`INSTR_RLOOP:
			begin
				depth_counter <= depth_counter - 1;

				if ((depth_counter - 1) == 0)
				begin
					pc <= pc;
					state <= `STATE_FETCH;
				end
			end

			default: begin end

			endcase
		end

		endcase
	end

	endcase
end

endmodule