/*------------------------------------------------------------------------------
 * File          : cigar_builder.v
 * Project       : RTL
 * Author        : eproel
 * Creation date : Oct 26, 2024
 * Description   :
 *------------------------------------------------------------------------------*/

module cigar_builder #(
	parameter MATRIX_SIZE = 16,    // Matrix size 16x16
	parameter CIGAR_WIDTH = 32,    // Max Width of CIGAR operation (to store count and type)
	parameter ARROW_WIDTH = 2      // Each arrow is 2-bits (00=Start, 01=Insertion, 10=Deletion, 11=Diagonal)
)(
	input clk,                     // Clock signal
	input rst_n,                   // Active low reset
	input [ARROW_WIDTH-1:0] arrow_table [MATRIX_SIZE-1:0][MATRIX_SIZE-1:0],  // 16x16 arrow matrix
	input [3:0] end_row,           // End position row
	input [3:0] end_col,           // End position col
	output [CIGAR_WIDTH-1:0] cigar_output[5:0],  // CIGAR string
	output [4:0] cigar_length,
	output reg done                // Signal when the operation is complete
);

// Internal registers
reg [3:0] curr_row, curr_col;  // Current position in the traceback
reg [3:0] count;               // Count of consecutive operations
reg [1:0] last_op;             // Last operation type (3=M, 1=I, 2=D)
reg [CIGAR_WIDTH-1:0] cigar [5:0];
reg [4:0] cigar_idx;           // CIGAR index for storing
reg [ARROW_WIDTH-1:0] current_arrow;  // Current arrow direction
// State machine for traceback
typedef enum reg [1:0] {
	IDLE       = 2'b00,
	TRACEBACK  = 2'b01,
	FINISH     = 2'b10
} state_t;

state_t state, next_state;

// State machine logic
always @(posedge clk or negedge rst_n) begin
	if (!rst_n)
		state <= IDLE;
	else
		state <= next_state;
end

// State transitions
always @* begin
	next_state = state;
	case (state)
		IDLE: begin
			if (end_row != 0 && end_col != 0)  // Begin traceback when end is valid
				next_state = TRACEBACK;
		end
		TRACEBACK: begin
			if (current_arrow == 2'b00)  // If we hit the "start" position (00)
				next_state = FINISH;
			if (current_arrow == 2'b11 && (curr_col ==0 || curr_row ==0))
				next_state = FINISH;
			if (current_arrow == 2'b10 && (curr_row ==0))
				next_state = FINISH;
			if (current_arrow == 2'b01 && (curr_col ==0))
				next_state = FINISH;
		end
		FINISH: begin
			next_state = IDLE;  // Finish and go back to IDLE state
		end
	endcase
end

// Traceback logic to move in the arrow table
always @(posedge clk or negedge rst_n) begin
	if (!rst_n) begin
		curr_row <= 0;
		curr_col <= 0;
		count <= 0;
		last_op <= 0;
		cigar_idx <= 0;
		done <= 0;
	end
	else begin
		case (state)
			IDLE: begin
				// Initialize the starting position
				curr_row <= end_row;
				curr_col <= end_col;
				count <= 0;
				last_op <= 0;
				cigar_idx <= 0;
				done <= 0;
			end
			TRACEBACK: begin
				current_arrow <= arrow_table[curr_row][curr_col];
				if (last_op != current_arrow) begin  // different operation than last one
					if (count > 0) begin
						cigar[cigar_idx] <= {count, last_op};  // Store previous operation
						cigar_idx <= cigar_idx + 1;
						count <= 0;

					end
				end
				// Handle traceback based on the arrow direction
				case (current_arrow)
					2'b00: begin  // Start of CIGAR (00)
						if (count > 0) begin
							cigar[cigar_idx] <= {count, last_op};  // Store the last operation
							cigar_idx <= cigar_idx + 1;
						end
						done <= 1;  // Traceback complete
					end

					2'b11: begin  // Diagonal (Match)
						last_op <= 2'b11;  // Mark as match
						count <= count + 1;
						curr_row <= curr_row - 1;
						curr_col <= curr_col - 1;
					end

					2'b01: begin  // Insertion (in query sequence)
						last_op <= 2'b01;  // Mark as insertion
						count <= count + 1;
						curr_col <= curr_col - 1;
					end

					2'b10: begin  // Deletion (in target sequence)
						last_op <= 2'b10;  // Mark as deletion
						count <= count + 1;
						curr_row <= curr_row - 1;
					end
				endcase
			end
			FINISH: begin
				if (count > 0) begin // save last operation
					cigar[cigar_idx] <= {count, last_op};  // Store the last operation
					cigar_idx <= cigar_idx + 1;
				end
				done <= 1;  // Set done signal
			end
		endcase
	end
end

// Output the last CIGAR string from memory when done
assign cigar_output = cigar;
assign cigar_length = cigar_idx;


endmodule
