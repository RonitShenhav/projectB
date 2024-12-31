module solver16x16(
input logic clk,
input logic reset,
input logic [1:0] letter1,
input logic [1:0] letter2,
input logic [7:0] up_val,
input logic [7:0] left_val,
input logic [7:0] diagonal_val,
input logic [3:0] tileNum,
input logic [7:0] offset,

output logic [3:0] tileNumOut,
output logic [7:0] offsetOut,
output logic [1:0] arrow,
output logic [7:0] val,
output logic valid
} 

wire [7:0] result_down, result_right, result_diag;

always_comb begin
	if(up_val > 1) begin
		result_down = up_val -7'b0000001;
	end
	else begin
		result_down = 7'b0;
	end
	if(left_val > 1)begin
		result_right = left_val -7'b0000001;
	end
	else begin
		result_right = 7'b0;
	end
	if(letter1 == letter2) begin
		result_diag = diagonal_val +7'b0000010;
	end
	else if (diagonal_val > 1)
		result_diag = diagonal_val -7'b0000001;
	end
	else begin
		result_diag = 7'b0;
	end
	
end

always @(posedge reset)begin

	if(result_down == 0 and result_right == 0 and result_diag == 0)begin
		val <= 0;
		arrow <= 2'b00;
	end
	else if(result_down > result_right)begin
		if(result_down > result_diag)begin
			val <= result_down;
			arrow <= 2'b01;
			valid <= 1'b1;
		end
		else begin
			val <= result_diag;
			arrow <= 2'b11;
			valid <= 1'b1;
		end
	end
	else if(result_down <= result_right)begin
		if(result_right > result_diag)begin
				val <= result_right;
				arrow <= 2'b10;
				valid <= 1'b1;
		end
		else begin
			val <= result_diag;
			arrow <= 2'b11;
			valid <= 1'b1;
		end
	end

end
assign tileNumOut = tileNum
assign offsetOut = offset
endmodule