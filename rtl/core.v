module core
(
	input wire clock,

	// Tape memory
	output wire tape_we,
	output wire [15:0] tape_addr,
	input wire [7:0] tape_data_read,
	output wire [7:0] tape_data_write,

	// Program ROM
	output wire [15:0] pmem_addr,
	input wire [2:0] pmem_data_read
);

// State definitions
`define STATE_WIDTH 3
`define STATE_RESET     `STATE_WIDTH'd0
`define STATE_FETCH     `STATE_WIDTH'd1
`define STATE_DECODE    `STATE_WIDTH'd2
`define STATE_EXECUTE   `STATE_WIDTH'd3
`define STATE_WRITEBACK `STATE_WIDTH'd4

// Instruction definitions
`define INSTR_WIDTH 3
`define INSTR_INC       `INSTR_WIDTH'd0
`define INSTR_DEC       `INSTR_WIDTH'd1
`define INSTR_INCSP     `INSTR_WIDTH'd2
`define INSTR_DECSP     `INSTR_WIDTH'd3
`define INSTR_INCPCZ    `INSTR_WIDTH'd4
`define INSTR_DECPCNZ   `INSTR_WIDTH'd5
`define INSTR_CIN       `INSTR_WIDTH'd6
`define INSTR_COUT      `INSTR_WIDTH'd7

// ALU definitions
`define ALU_OP_WIDTH 1
`define ALU_OP_INC      `ALU_OP_WIDTH'd0
`define ALU_OP_DEC      `ALU_OP_WIDTH'd1

// Comparator definitions
`define CMP_OP_WIDTH 1
`define CMP_OP_IS_Z     `ALU_OP_WIDTH'd0
`define CMP_OP_IS_NZ    `ALU_OP_WIDTH'd1

// Execution type, i.e. the type of operation performed on `STATE_EXECUTE
`define EXEC_WIDTH 2
`define EXEC_ALU        `EXEC_WIDTH'b01
`define EXEC_BRANCHING  `EXEC_WIDTH'b10

// Writeback destinations
`define WB_WIDTH 2
`define WB_PC       `WB_WIDTH'd0
`define WB_SP           `WB_WIDTH'd1
`define WB_TAPE         `WB_WIDTH'd2

// Program counter
reg [15:0] pc, nextpc;

// Stack pointer (i.e. tape pointer)
reg [15:0] sp;

// Opcode
reg [`INSTR_WIDTH-1:0] opcode;
reg [`EXEC_WIDTH-1:0] exec_type;

// ALU states
reg [`ALU_OP_WIDTH-1:0] alu_op;
reg [15:0] alu_data;

// Comparator states (for branching instructions)
reg [`CMP_OP_WIDTH-1:0] cmp_op;
reg [7:0] cmp_data;

// Writeback destination state
reg [`WB_WIDTH-1:0] wb_destination;
reg wb_en;

// Machine state
reg [`STATE_WIDTH-1:0] state, nextstate;
initial assign state = `STATE_RESET;

always @(nextstate)
begin
	case (state)
	default:          nextstate = `STATE_RESET;
	`STATE_RESET:	  nextstate = `STATE_FETCH;
	`STATE_FETCH:     nextstate = `STATE_DECODE;
	`STATE_DECODE:    nextstate = `STATE_EXECUTE;
	`STATE_EXECUTE:   nextstate = `STATE_WRITEBACK;
	`STATE_WRITEBACK: nextstate = `STATE_FETCH;
	endcase
end

always @(sp, pc)
begin
	tape_addr = sp;
	pmem_addr = pc;
end

always @(posedge clock)
begin
	state <= nextstate;

	alu_data <= 0; // to clean up the upper bits
	tape_we <= 0;

	// Handle what the current state is supposed to do
	case (state)

	`STATE_RESET:
	begin
		// Reset regs
		pc <= 0;
		sp <= 0;
	end

	`STATE_FETCH:
	begin
		// Fetch the opcode
		opcode <= pmem_data_read[`INSTR_WIDTH-1:0];
	end

	`STATE_DECODE:
	begin
		case (opcode)

		`INSTR_INC:
		begin
			exec_type <= `EXEC_ALU;

			alu_data[7:0] <= tape_data_read;
			alu_op <= `ALU_OP_INC;

			wb_destination <= `WB_TAPE;
			wb_en <= 1;
		end

		`INSTR_DEC:
		begin
			exec_type <= `EXEC_ALU;

			alu_data[7:0] <= tape_data_read;
			alu_op <= `ALU_OP_DEC;

			wb_destination <= `WB_TAPE;
			wb_en <= 1;
		end

		`INSTR_INCSP:
		begin
			exec_type <= `EXEC_ALU;

			alu_data <= sp;
			alu_op <= `ALU_OP_INC;

			wb_destination <= `WB_SP;
			wb_en <= 1;
		end

		`INSTR_DECSP:
		begin
			exec_type <= `EXEC_ALU;

			alu_data <= sp;
			alu_op <= `ALU_OP_DEC;

			wb_destination <= `WB_SP;
			wb_en <= 1;
		end

		`INSTR_INCPCZ:
		begin
			exec_type <= `EXEC_ALU | `EXEC_BRANCHING;

			alu_data <= pc;
			alu_op <= `ALU_OP_INC;

			cmp_data <= tape_data_read;
			cmp_op <= `CMP_OP_IS_Z;

			wb_destination <= `WB_PC;
			wb_en <= 0;
		end

		`INSTR_DECPCNZ:
		begin
			exec_type <= `EXEC_ALU | `EXEC_BRANCHING;

			alu_data <= pc;
			alu_op <= `ALU_OP_DEC;

			cmp_data <= tape_data_read;
			cmp_op <= `CMP_OP_IS_NZ;

			wb_destination <= `WB_PC;
			wb_en <= 0;
		end

		`INSTR_CIN:
		begin

		end

		`INSTR_COUT:
		begin
			$display(tape_data_read);
		end

		endcase
	end

	`STATE_EXECUTE:
	begin
		case (exec_type)

		`EXEC_ALU: // HACKY: TEMP: just do flags instead
		begin

			case (alu_op)
			`ALU_OP_INC: alu_data <= alu_data + 1;
			`ALU_OP_DEC: alu_data <= alu_data - 1;
			default: begin end
			endcase

		end

		`EXEC_BRANCHING:
		begin

			case (cmp_op)
			`CMP_OP_IS_Z:  if (cmp_data == 0) wb_en <= 1;
			`CMP_OP_IS_NZ: if (cmp_data != 0) wb_en <= 1;
			default: begin end
			endcase

		end

		default: begin end

		endcase
	end

	`STATE_WRITEBACK:
	begin
		pc <= nextpc;
		nextpc <= pc + 1;

		if (wb_en)
		begin
			case (wb_destination)

			`WB_PC:
			begin
				nextpc <= nextpc + 2; // Overwrite PC
			end

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

	endcase
end

endmodule