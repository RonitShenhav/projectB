module tb_smith_waterman_top;

    // Testbench signals
    reg clk;
    reg rst;
    reg start;
    reg [1:0] seqA;
    reg [1:0] seqB;
    wire done;
    wire [7:0] score;

    // Instantiate the top module
    smith_waterman_top uut (
        .clk(clk),
        .rst(rst),
        .start(start),
        .seqA(seqA),
        .seqB(seqB),
        .done(done),
        .score(score)
    );

    // Clock generation
    always begin
        #5 clk = ~clk; // 10 ns period
    end

    // Test sequence
    initial begin
        // Initialize signals
        clk = 0;
        rst = 0;
        start = 0;
        seqA = 2'b00;
        seqB = 2'b00;

        // Reset the system
        rst = 1;
        #10;
        rst = 0;

        // Start the computation
        start = 1;
        seqA = 2'b01; // Example input
        seqB = 2'b10; // Example input
        #10;
        start = 0;

        // Wait for the computation to complete
        wait(done);
        #10;

        // Display results
        $display("Max score: %d", score);

        // End simulation
        $finish;
    end

endmodule