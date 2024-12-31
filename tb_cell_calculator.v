module tb_cell_calculator;

    // Testbench signals
    reg [1:0] score_diag;
    reg [1:0] score_up;
    reg [1:0] score_left;
    reg [7:0] match_score;
    reg [7:0] gap_penalty;
    wire [7:0] score;
    wire [1:0] direction;

    // Instantiate the cell_calculator module
    cell_calculator uut (
        .score_diag(score_diag),
        .score_up(score_up),
        .score_left(score_left),
        .match_score(match_score),
        .gap_penalty(gap_penalty),
        .score(score),
        .direction(direction)
    );

    // Test sequence
    initial begin
        // Initialize signals
        score_diag = 2'b00;
        score_up = 2'b00;
        score_left = 2'b00;
        match_score = 8'h02;
        gap_penalty = 8'hFE;

        // Wait for global reset
        #10;

        // Test case 1: Diagonal score is highest
        score_diag = 2'b10; // 8'b00000010
        score_up = 2'b01;   // 8'b00000001
        score_left = 2'b00; // 8'b00000000
        #10;
        assert(score == (8'b00000010 + match_score));
        assert(direction == 2'b00);

        // Test case 2: Up score is highest
        score_diag = 2'b01; // 8'b00000001
        score_up = 2'b10;   // 8'b00000010
        score_left = 2'b00; // 8'b00000000
        #10;
        assert(score == (8'b00000010 + gap_penalty));
        assert(direction == 2'b01);

        // Test case 3: Left score is highest
        score_diag = 2'b01; // 8'b00000001
        score_up = 2'b00;   // 8'b00000000
        score_left = 2'b10; // 8'b00000010
        #10;
        assert(score == (8'b00000010 + gap_penalty));
        assert(direction == 2'b10);

        // End simulation
        $finish;
    end

endmodule