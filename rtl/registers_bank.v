module registers_bank (
	input clock,
	input [4:0] rd,
	input [4:0] rs,
	input [4:0] rt,
	input en,
	input [31:0] data,

	output reg [31:0] data_rs,
	output reg [31:0] data_rt
	
);

integer i;
reg [31:0] registers [15:0];

initial begin

  for (i = 0; i < 32; i = i + 1) begin
    registers[i] = 0;
  end
  
  data_rs = 0;
  data_rt = 0;
end

endmodule