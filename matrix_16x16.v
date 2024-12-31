module matrix_16x16 (
    input clk,
    input rst,
    input start,
    input [1:0] seqA[0:15],  // Single element from sequence A (2-bit)
    input [1:0] seqB[0:15],  // Single element from sequence B (2-bit)
	input [7:0] firstRow[0:15],
	input [7:0] firstCol[0:15],
	input [7:0] diagonalCell,
    output reg done,
    output reg [7:0] max_score,
	output reg [1:0] traceback_matrix [0:15][0:15],
	output logic [127:0] lastRow,
	output logic [127:0] lastCol,
	output logic [7:0] diagonalOut;
);

    parameter MATRIX_SIZE = 16;
    parameter K = 16; // Number of cell_calculator instances
    parameter MATCH_SCORE = 8'h02; // 8-bit match score
    parameter GAP_PENALTY = 8'hFE; // 8-bit gap penalty (equivalent to -2 in 2's complement)

  
    reg [1:0] traceback_matrix [0:MATRIX_SIZE-1][0:MATRIX_SIZE-1];

    wire [7:0] score_diag, score_up, score_left;
	wire [7:0] cell_score_prev2 [0:K-1];
	wire [7:0] cell_score_prev [0:K-1];
    wire [7:0] cell_score [0:K-1];
    wire [1:0] direction [0:K-1];
	wire [7:0] interim_max[0:2*K-1]

    // Generate instances of cell_calculator
    genvar i, j, k;
    generate
        for (i = 0; i < 2*MATRIX_SIZE; i = i + 1) begin : row
				if(i<MATRIX_SIZE) begin
					for (j = 0; j <= i; j = j + 1) begin : calc_instance
						cell_calculator calc (
							.score_diag(score_diag),
							.score_up(score_up),
							.score_left(score_left),
							.match_score(MATCH_SCORE),
							.gap_penalty(GAP_PENALTY),
							.score(cell_score[j]),
							.direction(direction[j])
						);
					end
				end else begin
					for (j = 0; j < 2*MATRIX_SIZE-i ; j = j + 1) begin : calc_instance
							cell_calculator calc (
								.score_diag(score_diag),
								.score_up(score_up),
								.score_left(score_left),
								.match_score(MATCH_SCORE),
								.gap_penalty(GAP_PENALTY),
								.score(cell_score[j]),
								.direction(direction[j])
							);
						end
					end
				
            
        end
		
		max16 max(.values(cell_score), .max(interim_max[i]));
		
    endgenerate
	
	max32 max2(.values(interim_max), .max(max_score);

    // State machine parameters
    reg [1:0] state, next_state;
    localparam IDLE = 2'b00, CALC = 2'b01, DONE = 2'b10;

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            state <= IDLE;
            done <= 0;
            max_score <= 0;
			
			for(i=0; i<MATRIX_SIZE;i=i+1)begin
				cell_score_prev2[i] <= cell_score_prev[i];
				cell_score_prev[i] <= cell_score[i]
			end
			
			
        end else begin
            state <= next_state;
            if (state == DONE) begin
                done <= 1;
            end else begin
                done <= 0;
            end
        end
    end
	
	//STATE - MACHINE
    always @(*) begin
        case (state)
            IDLE: begin
                if (start) begin
                    next_state = CALC;
                end else begin
                    next_state = IDLE;
                end
            end
            CALC: begin
                if (i == 2*MATRIX_SIZE - 1 && j == i) begin
                    next_state = DONE;
                end else begin
                    next_state = CALC;
                end
            end
            DONE: begin
                next_state = IDLE;
            end
            default: begin
                next_state = IDLE;
            end
        endcase
    end

    always @(posedge clk) begin
        if (state == IDLE) begin
            // Initialize traceback_matrix
            for (i = 0; i < 2*MATRIX_SIZE; i = i + 1) begin
				if(i <MATRIX_SIZE)begin
				
					for (j = 0; j <= i; j = j + 1) begin
						traceback_matrix[i][j] = 0;
					end
				end else
					for (j = 2*MATRIX_SIZE-1; j >= i; j = j - 1) begin
						traceback_matrix[i][j] = 0;
				end
            end
        end else if (state == CALC) begin
            // Compute scores for each cell
			
			for (i = 0; i < 2*MATRIX_SIZE; i = i + 1) begin
				if(i <MATRIX_SIZE)begin
				
					for (j = 0; j <= i; j = j + 1) begin
                    // Prepare inputs for cell_calculator
						if (i == 0) begin // i=0 => j=0
							score_diag = diagonalCell;
							score_up = firstRow[0];
							score_left = firstCol[0];
						end else if (j==0) begin //j=0 first column
							score_diag = firstCol[j-1];
							score_up = cell_score_prev[j]
							score_left = cell_score_prev[j-1];
						end else if (j==i) begin
							score_diag = firstRow[j-1];
							score_up = firstRow[j];
							score_left = cell_score_prev[j-1];
						end else begin
							score_diag = cell_score_prev2[j-1];
							score_up = cell_score_prev[j];
							score_left = cell_score_prev[j-1
						end
					end
				end else begin
					for (j = 0; j < 2*MATRIX_SIZE-i; j = j + 1) begin
						score_diag = cell_score_prev2[j+1];
                        score_up = cell_score_prev[j+1];
                        score_left = cell_score_prev[j];
					end
					
				end

                    // Assign inputs and calculate score for each cell
                    for (j = 0; j < 2*MATRIX_SIZE-i; j = j + 1) begin
                        // Use the k-th instance of cell_calculator
                        traceback_matrix[i-j][j] = direction[j];

                    end
                end
            end
        end
		
    end

endmodule