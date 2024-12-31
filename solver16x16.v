module solver16x16(
	input logic clk,
	input logic reset,
	input logic [3:0] tileNum,
	input logic [31:0] S1,
	input logic [31:0] S2,
	input logic [127:0] firstRow,
	input logic [127:0] firstCol,
	input logic [7:0] diagonalCell,
	
	output logic [31:0][31:0] sw16,
	output logic [127:0] lastRow,
	output logic [127:0] lastCol,
	output logic [7:0] diagonalOut,
	output logic [7:0] maxValue,//temporary length
	output logic [3:0] maxIdx
	output logic [3:0] tileNumOut,
	output logic [4:0] connectRow,
	output logic [4:0] connectCol,
	output logic valid
	);



always_ff @(posedge clk)begin

end

assign tileNumOut = tileNum;
endmodule